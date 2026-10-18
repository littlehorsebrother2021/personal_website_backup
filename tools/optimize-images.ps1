<#
optimize-images.ps1

压缩博客配图：把过大的照片缩到合理宽度并重新编码，显著减小仓库与页面体积。

为什么要做
----------
手机/相机照片动辄 3000~5000px、单张 3~5MB，而博客正文里按 100% 宽度显示，
1600~1920px 已经足够清晰。不压缩的话：仓库膨胀、读者加载一张图要等好几秒。

默认策略
--------
* 只处理 .jpg / .jpeg（PNG 截图通常已是小图，加 -IncludePng 才处理）
* 宽度超过 -MaxWidth 才缩放
* 文件大于 -MinBytes（默认 300KB）才重新编码
* 重新编码后如果没省下 5% 以上，就保持原样
* 原图不另存：仓库的 git 历史就是备份，随时可以还原

用法
----
  # 先看会改什么、能省多少（不改文件）
  tools\optimize-images.ps1 -DryRun

  # 真正执行
  tools\optimize-images.ps1

  # 更激进：压到 1600px、质量 80
  tools\optimize-images.ps1 -MaxWidth 1600 -Quality 80

  # 连 PNG 一起处理
  tools\optimize-images.ps1 -IncludePng

参数
----
  -Path        要扫描的目录（默认 source/_posts）
  -MaxWidth    最大宽度，超过则等比缩放（默认 1920）
  -Quality     JPEG 质量 1-100（默认 85）
  -MinBytes    小于这个体积的文件跳过（默认 300KB）
  -IncludePng  同时处理 PNG
  -DryRun      只报告，不改文件

还原
----
  某张图压坏了想恢复：
    git log --oneline -- 图片路径
    git checkout <压缩前的提交> -- 图片路径
#>
param(
    [string]$Path = 'source/_posts',
    [int]$MaxWidth = 1920,
    [int]$Quality = 85,
    [int]$MinBytes = 307200,
    [switch]$IncludePng,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$target = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $root $Path }

if (-not (Test-Path -LiteralPath $target)) { throw "目录不存在：$target" }
if ($Quality -lt 1 -or $Quality -gt 100) { throw '-Quality 必须在 1-100 之间' }

$patterns = @('.jpg', '.jpeg')
if ($IncludePng) { $patterns += '.png' }

$files = Get-ChildItem -LiteralPath $target -Recurse -File |
    Where-Object { $patterns -contains $_.Extension.ToLower() } |
    Sort-Object Length -Descending

Write-Host ''
Write-Host ("扫描 {0}" -f $target.Replace($root, '.')) -ForegroundColor Cyan
Write-Host ("候选 {0} 个文件，共 {1:N1} MB | 规则：宽度>{2}px 才缩放，体积>{3}KB 才重编码，质量 {4}" -f `
    $files.Count, (($files | Measure-Object Length -Sum).Sum / 1MB), $MaxWidth, [math]::Round($MinBytes/1KB), $Quality)
Write-Host ''

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
    [System.Drawing.Imaging.Encoder]::Quality, [long]$Quality)

$totalBefore = 0
$totalAfter = 0
$changed = 0
$skipped = 0
$rows = @()

foreach ($f in $files) {
    if ($f.Length -lt $MinBytes) { $skipped++; continue }

    $img = $null
    try { $img = [System.Drawing.Image]::FromFile($f.FullName) } catch { $skipped++; continue }

    $needResize = $img.Width -gt $MaxWidth
    $origW = $img.Width
    $scale = if ($needResize) { $MaxWidth / $img.Width } else { 1.0 }
    $newW = [int][Math]::Round($img.Width * $scale)
    $newH = [int][Math]::Round($img.Height * $scale)

    $isPng = $f.Extension.ToLower() -eq '.png'
    $tmp = Join-Path $env:TEMP ("opt_{0}.tmp" -f [guid]::NewGuid().ToString('N'))

    try {
        if ($needResize) {
            $bmp = New-Object System.Drawing.Bitmap($newW, $newH)
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $g.DrawImage($img, 0, 0, $newW, $newH)
            $g.Dispose()
            if ($isPng) { $bmp.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png) }
            else { $bmp.Save($tmp, $codec, $encParams) }
            $bmp.Dispose()
        } else {
            if ($isPng) { $skipped++; continue }
            $bmp = New-Object System.Drawing.Bitmap($img)
            $bmp.Save($tmp, $codec, $encParams)
            $bmp.Dispose()
        }
    } finally {
        $img.Dispose()
    }

    $newSize = (Get-Item -LiteralPath $tmp).Length
    if ($newSize -ge ($f.Length * 0.95)) {
        Remove-Item -LiteralPath $tmp -Force
        $skipped++
        continue
    }

    $rows += [pscustomobject]@{
        文件 = $f.FullName.Replace($root, '.')
        原宽 = $origW
        新宽 = $newW
        原KB = [math]::Round($f.Length / 1KB, 0)
        新KB = [math]::Round($newSize / 1KB, 0)
        节省 = (1 - $newSize / $f.Length)
    }

    $totalBefore += $f.Length
    $totalAfter += $newSize
    $changed++

    if (-not $DryRun) {
        Copy-Item -LiteralPath $tmp -Destination $f.FullName -Force
    }
    Remove-Item -LiteralPath $tmp -Force
}

Write-Host ''
if ($changed -eq 0) {
    Write-Host '没有需要处理的文件（都很小或已经压缩过）。' -ForegroundColor Green
    return
}

$rows | ForEach-Object {
    "  {0,-56} {1,5}px -> {2,4}px   {3,6}KB -> {4,5}KB   省 {5:P0}" -f `
        $_.文件, $_.原宽, $_.新宽, $_.原KB, $_.新KB, $_.节省
}

Write-Host ''
Write-Host ("处理 {0} 个，跳过 {1} 个 | {2:N1} MB -> {3:N1} MB，节省 {4:N1} MB ({5:P0})" -f `
    $changed, $skipped, ($totalBefore/1MB), ($totalAfter/1MB),
    (($totalBefore - $totalAfter)/1MB), (1 - $totalAfter/$totalBefore)) -ForegroundColor Cyan

if ($DryRun) {
    Write-Host ''
    Write-Host '[DryRun] 未修改任何文件。确认后去掉 -DryRun 再执行。' -ForegroundColor Yellow
    Write-Host '还原方法：git checkout <压缩前的提交> -- <图片路径>' -ForegroundColor DarkGray
} else {
    Write-Host ''
    Write-Host '完成。建议接着执行：hexo clean && hexo generate 验证页面。' -ForegroundColor Green
}
