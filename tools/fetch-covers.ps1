<#
fetch-covers.ps1

从网络自动抓取高清壁纸，替换站点背景（banner）与文章默认封面（featureimages）。

设计要点
--------
* 这是「一次性维护脚本」，不是 Hexo 插件：构建期联网会让 hexo generate 不可复现、
  离线构建失败，还会让每次部署都推一堆无意义变更。所以由你手动触发，产物入库。
* 下载的原图只落在 assets/incoming/（已 gitignore），真正入库的是裁剪后的小图。
* 裁剪、重编号、同步主题配置全部复用 update-covers.ps1，不重复造轮子。

用法
----
  # 交互式（推荐，回答 3 个问题即可）
  npm run covers
  powershell -ExecutionPolicy Bypass -File tools\fetch-covers.ps1 -Interactive

  # 命令行
  tools\fetch-covers.ps1 -Source bing   -Count 9  -Target feature -Build
  tools\fetch-covers.ps1 -Source picsum -Count 12 -Target feature -Build
  tools\fetch-covers.ps1 -Source picsum -Keep -Build      # 保留旧图，追加新图
  tools\fetch-covers.ps1 -Source bing -Count 3 -DryRun    # 只下载校验，不改站点

参数
----
  -Source      bing | picsum | loliapi        图源（不填则进入交互菜单）
  -Count       下载张数（banner 固定 7；不填时 feature=9 / banner=7）
  -Target      feature | banner | both        替换对象（默认 feature）
  -Page        picsum 起始页（默认随机 1-10）
  -MinWidth    最小原始宽度，低于此值丢弃（默认 1600）
  -OutFolder   下载暂存目录（默认 assets/incoming/<时间戳>）
  -Keep        保留当前已有的封面，把新图追加在后面
  -DryRun      只下载并校验，不替换、不构建
  -Build       替换完成后自动 hexo clean && hexo generate
  -Interactive 强制进入交互菜单

图源说明（2026-10-17 实测）
--------------------------
  bing     必应每日壁纸，3840x2160，一次最多 8 张，画质最好；版权归摄影师，个人欣赏可用。
  picsum   Lorem Picsum（Unsplash 图库），量大约 1000 张，可翻页，授权宽松、可商用。
  loliapi  二次元/风景随机图，国内直连快，但来源与授权不明，建议仅自用。
#>
param(
    [ValidateSet('bing', 'picsum', 'loliapi')]
    [string]$Source,

    [int]$Count = 0,

    [ValidateSet('feature', 'banner', 'both')]
    [string]$Target = 'feature',

    [int]$Page = 0,

    [int]$MinWidth = 1600,

    [string]$OutFolder,

    [switch]$Keep,
    [switch]$Build,
    [switch]$DryRun,
    [switch]$Interactive
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$updateScript = Join-Path $PSScriptRoot 'update-covers.ps1'
$incomingRoot = Join-Path $root 'assets\incoming'
$ledgerPath = Join-Path $incomingRoot 'used-picsum.json'

try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch { }
$UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36'

# ---------------------------------------------------------------- 交互菜单
function Read-Choice {
    param([string]$Prompt, [string[]]$Options, [int]$Default = 1)
    Write-Host ''
    Write-Host $Prompt
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host ("    {0}) {1}" -f ($i + 1), $Options[$i])
    }
    $raw = Read-Host ("  输入 1-{0} [{1}]" -f $Options.Count, $Default)
    if ([string]::IsNullOrWhiteSpace($raw)) { return $Default }
    $n = 0
    if (-not [int]::TryParse($raw.Trim(), [ref]$n) -or $n -lt 1 -or $n -gt $Options.Count) {
        Write-Host '  输入无效，使用默认值。' -ForegroundColor Yellow
        return $Default
    }
    return $n
}

if ($Interactive -or -not $Source) {
    Write-Host ''
    Write-Host '=== 壁纸替换向导 ===' -ForegroundColor Cyan

    $srcIdx = Read-Choice '请选择壁纸来源：' @(
        '必应每日壁纸    4K 风光/人文，一次最多 8 张',
        'Lorem Picsum    Unsplash 摄影，量大约 1000 张',
        'Loliapi          二次元/风景，国内直连'
    ) 1
    $Source = @('bing', 'picsum', 'loliapi')[$srcIdx - 1]

    $tgtIdx = Read-Choice '用来做什么：' @(
        '文章封面（640x426）',
        '站点背景（1280x720，固定 7 张按星期轮换）',
        '两者都要'
    ) 1
    $Target = @('feature', 'banner', 'both')[$tgtIdx - 1]

    $defaultCount = if ($Target -eq 'banner') { 7 } else { 9 }
    if ($Count -le 0) {
        $raw = Read-Host ("  需要几张？[{0}]" -f $defaultCount)
        if ([string]::IsNullOrWhiteSpace($raw)) { $Count = $defaultCount }
        elseif (-not [int]::TryParse($raw.Trim(), [ref]$Count)) { $Count = $defaultCount }
    }

    $keepRaw = Read-Host '  保留现有封面并追加？[y/N]'
    if ($keepRaw -match '^(y|yes|是)$') { $Keep = $true }

    $dryRaw = Read-Host '  先试跑（只下载不改站点）？[y/N]'
    if ($dryRaw -match '^(y|yes|是)$') { $DryRun = $true }

    if (-not $DryRun) {
        $buildRaw = Read-Host '  完成后立即构建？[Y/n]'
        if ([string]::IsNullOrWhiteSpace($buildRaw) -or $buildRaw -match '^(y|yes|是)$') { $Build = $true }
    }
}

if ($Count -le 0) { $Count = if ($Target -eq 'banner') { 7 } else { 9 } }
if ($Target -in @('banner', 'both') -and $Count -lt 7) {
    Write-Warning "站点背景需要 7 张（周日→周六各一张），已自动调整为 7。"
    $Count = 7
}
if ($Target -eq 'banner' -and $Count -gt 7) {
    Write-Warning "站点背景只用到 0-6.jpg 共 7 张，已截断为 7。"
    $Count = 7
}

$featureDir = Join-Path $root 'themes\hexo-theme-matery\source\medias\featureimages'
$bannerDir = Join-Path $root 'themes\hexo-theme-matery\source\medias\banner'

if (-not $OutFolder) {
    $OutFolder = Join-Path $incomingRoot (Get-Date -Format 'yyyyMMdd-HHmmss')
}
New-Item -ItemType Directory -Force -Path $OutFolder | Out-Null

Write-Host ''
Write-Host ("来源 {0} ｜ 目标 {1} ｜ 数量 {2} ｜ 暂存 {3}" -f $Source, $Target, $Count, $OutFolder) -ForegroundColor Cyan

# ---------------------------------------------------------------- 工具函数
function Save-AsJpeg {
    param([string]$InFile, [string]$OutFile)
    Add-Type -AssemblyName System.Drawing
    $img = [System.Drawing.Image]::FromFile($InFile)
    try {
        $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
            Where-Object { $_.MimeType -eq 'image/jpeg' }
        $p = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $p.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
            [System.Drawing.Imaging.Encoder]::Quality, [long]92)
        $img.Save($OutFile, $codec, $p)
        return @{ Width = $img.Width; Height = $img.Height }
    } finally {
        $img.Dispose()
    }
}

function Get-RemoteFile {
    param([string]$Url, [string]$OutFile, [int]$Retry = 3)
    for ($i = 1; $i -le $Retry; $i++) {
        try {
            Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -TimeoutSec 60 `
                -Headers @{ 'User-Agent' = $UA } | Out-Null
            if ((Get-Item -LiteralPath $OutFile).Length -gt 10KB) { return $true }
            throw '文件过小，可能是错误页'
        } catch {
            if ($i -eq $Retry) { Write-Warning ("下载失败 {0}：{1}" -f $Url, $_.Exception.Message); return $false }
            Start-Sleep -Seconds (2 * $i)
        }
    }
    return $false
}

$list = New-Object System.Collections.ArrayList
$stagingPrefix = if ($Keep) { 'a-keep-' } else { 'b-new-' }
$seq = 0
$newAdded = 0

function Add-Image {
    param([string]$Url, [string]$Label, [hashtable]$Meta)

    $script:seq += 1
    $tmp = Join-Path $OutFolder ('_tmp_{0}.bin' -f $script:seq)
    Write-Host ("  [{0}/{1}] 下载 {2}" -f $script:seq, $Count, $Label) -NoNewline

    if (-not (Get-RemoteFile -Url $Url -OutFile $tmp)) { Write-Host '  ✗' -ForegroundColor Red; return }

    $name = '{0}{1:D2}.jpg' -f $stagingPrefix, ($script:list.Count)
    $dest = Join-Path $OutFolder $name
    try {
        $info = Save-AsJpeg -InFile $tmp -OutFile $dest
    } catch {
        Write-Host ('  ✗ 无法解码：{0}' -f $_.Exception.Message) -ForegroundColor Red
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
        return
    }
    Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue

    if ($info.Width -lt $MinWidth) {
        Write-Host ("  ✗ 宽度只有 {0}px（要求 ≥ {1}）" -f $info.Width, $MinWidth) -ForegroundColor Yellow
        Remove-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue
        return
    }

    $meta['file'] = $name
    $meta['width'] = $info.Width
    $meta['height'] = $info.Height
    $null = $script:list.Add($meta)
    $script:newAdded += 1
    Write-Host ("  ✓ {0}x{1}" -f $info.Width, $info.Height) -ForegroundColor Green
}

# ---------------------------------------------------------------- 保留旧图
$keepCount = 0
if ($Keep) {
    $keepDirs = @()
    if ($Target -in @('feature', 'both')) { $keepDirs += $featureDir }
    if ($Target -in @('banner', 'both')) { $keepDirs += $bannerDir }
    $keepDirs = $keepDirs | Select-Object -Unique
    foreach ($d in $keepDirs) {
        if (-not (Test-Path -LiteralPath $d)) { continue }
        $old = Get-ChildItem -LiteralPath $d -File -Filter *.jpg |
            Where-Object { $_.BaseName -match '^\d+$' } |
            Sort-Object { [int]$_.BaseName }
        foreach ($f in $old) {
            $dest = Join-Path $OutFolder ('a-keep-{0:D2}.jpg' -f $keepCount)
            Copy-Item -LiteralPath $f.FullName -Destination $dest -Force
            $null = $script:list.Add(@{ source = 'local-keep'; file = ('a-keep-{0:D2}.jpg' -f $keepCount); origin = $f.Name })
            $keepCount += 1
        }
        break
    }
    if ($keepCount -gt 0) { Write-Host ("沿用旧图 {0} 张" -f $keepCount) -ForegroundColor Cyan }
}

# ---------------------------------------------------------------- 各图源
switch ($Source) {

    'bing' {
        if ($Count -gt 8) {
            Write-Warning '必应一次只提供最近 8 天，超过部分会自动跳过。'
        }
        Write-Host '正在读取必应壁纸列表...'
        $json = Invoke-RestMethod -Uri 'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=8&mkt=zh-CN' `
            -TimeoutSec 30 -Headers @{ 'User-Agent' = $UA }
        $items = @($json.images)
        Write-Host ("可选 {0} 张" -f $items.Count)

        foreach ($img in $items) {
            if ($newAdded -ge $Count) { break }
            $origin = 'https://www.bing.com' + $img.urlbase
            Add-Image -Url ($origin + '_UHD.jpg') -Label $img.startdate -Meta @{
                source = 'bing'
                origin = $origin
                date   = $img.startdate
                credit = $img.copyright
            }
        }
    }

    'picsum' {
        $used = @()
        if (Test-Path -LiteralPath $ledgerPath) {
            try { $used = @([IO.File]::ReadAllText($ledgerPath) | ConvertFrom-Json) } catch { $used = @() }
        }
        if ($Page -le 0) { $Page = Get-Random -Minimum 1 -Maximum 11 }
        Write-Host ("正在读取 Picsum 第 {0} 页列表..." -f $Page)

        $fetched = Invoke-RestMethod -Uri ("https://picsum.photos/v2/list?page={0}&limit=100" -f $Page) `
            -TimeoutSec 30 -Headers @{ 'User-Agent' = $UA }

        $candidates = @($fetched) | Where-Object {
            [int]$_.width -ge $MinWidth -and ($used -notcontains $_.id)
        } | Sort-Object { Get-Random }

        Write-Host ("候选 {0} 张" -f @($candidates).Count)

        $w = 1920
        $h = if ($Target -eq 'banner') { 1080 } else { 1280 }

        foreach ($it in $candidates) {
            if ($newAdded -ge $Count) { break }
            $url = "https://picsum.photos/id/$($it.id)/$w/$h"
            $before = $newAdded
            Add-Image -Url $url -Label ("id={0} by {1}" -f $it.id, $it.author) -Meta @{
                source = 'picsum'
                origin = $it.url
                id     = $it.id
                credit = $it.author
            }
            if ($newAdded -gt $before) { $used += $it.id }
        }

        New-Item -ItemType Directory -Force -Path $incomingRoot | Out-Null
        $used = $used | Select-Object -Unique
        [IO.File]::WriteAllText($ledgerPath, ($used | ConvertTo-Json -Compress), (New-Object System.Text.UTF8Encoding($false)))
    }

    'loliapi' {
        Write-Warning 'Loliapi 图片来源与授权不明，建议只用于试玩，不要用于正式封面。'
        for ($i = 1; $i -le $Count; $i++) {
            if ($newAdded -ge $Count) { break }
            Add-Image -Url 'https://www.loliapi.com/acg/pe/' -Label 'loliapi' -Meta @{
                source = 'loliapi'
                origin = 'https://www.loliapi.com/acg/pe/'
                credit = 'unknown'
            }
        }
    }
}

# ---------------------------------------------------------------- 结果汇总
$got = @(Get-ChildItem -LiteralPath $OutFolder -File -Filter *.jpg | Sort-Object Name)
Write-Host ''
Write-Host ("实际可用 {0} 张（其中沿用旧图 {1} 张）" -f $got.Count, $keepCount) -ForegroundColor Cyan

if ($got.Count -eq 0) {
    throw '没有拿到任何可用图片，已中止，站点封面未改动。'
}

$manifestPath = Join-Path $OutFolder 'sources.json'
[IO.File]::WriteAllText($manifestPath, ($list | ConvertTo-Json -Depth 4), (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("来源记录：{0}" -f $manifestPath)

if ($DryRun) {
    Write-Host ''
    Write-Host '[DryRun] 只下载校验，未改动站点。确认满意后去掉 -DryRun 再跑一次。' -ForegroundColor Yellow
    return
}

# ---------------------------------------------------------------- 调用裁剪脚本
$invokeArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $updateScript)
if ($Target -in @('feature', 'both')) { $invokeArgs += @('-FeatureFolder', $OutFolder) }
if ($Target -in @('banner', 'both')) { $invokeArgs += @('-BannerFolder', $OutFolder) }

Write-Host ''
Write-Host '[1/3] 裁剪并写入主题...' -ForegroundColor Cyan
$psHost = 'powershell'
if (-not (Get-Command powershell -ErrorAction SilentlyContinue)) { $psHost = 'pwsh' }
& $psHost @invokeArgs
if ($LASTEXITCODE -ne 0) { throw 'update-covers.ps1 执行失败' }

# 清理多余编号（替换语义：新图更少时，旧的多余文件要删掉）
function Remove-Stale {
    param([string]$Dir, [int]$KeepCount)
    if (-not (Test-Path -LiteralPath $Dir)) { return }
    Get-ChildItem -LiteralPath $Dir -File -Filter *.jpg |
        Where-Object { $_.BaseName -match '^\d+$' -and [int]$_.BaseName -ge $KeepCount } |
        ForEach-Object {
            Remove-Item -LiteralPath $_.FullName -Force
            Write-Host ("  清理多余 {0}" -f $_.Name)
        }
}

Write-Host '[2/3] 清理多余编号...' -ForegroundColor Cyan
if ($Target -in @('feature', 'both')) { Remove-Stale -Dir $featureDir -KeepCount $got.Count }
if ($Target -in @('banner', 'both')) { Remove-Stale -Dir $bannerDir -KeepCount $got.Count }

# ---------------------------------------------------------------- 构建
if ($Build) {
    Write-Host '[3/3] 构建站点...' -ForegroundColor Cyan
    $nodeExe = (Get-Command node -ErrorAction SilentlyContinue).Source
    if (-not $nodeExe) {
        foreach ($p in @("$env:ProgramFiles\nodejs\node.exe", "${env:ProgramFiles(x86)}\nodejs\node.exe", "$env:LOCALAPPDATA\Programs\nodejs\node.exe")) {
            if ($p -and (Test-Path -LiteralPath $p)) { $nodeExe = $p; break }
        }
    }
    if (-not $nodeExe) {
        Write-Warning '找不到 node，已跳过构建。请手动运行 npm run build。'
    } else {
        $hexoEntry = Join-Path $root 'node_modules\hexo\bin\hexo'
        & $nodeExe $hexoEntry clean
        & $nodeExe $hexoEntry generate
        if ($LASTEXITCODE -ne 0) { throw 'hexo generate 失败' }
    }
} else {
    Write-Host '[3/3] 已跳过构建（加 -Build 可自动构建）' -ForegroundColor DarkGray
}

Write-Host ''
Write-Host '完成。原始大图在 assets/incoming/（不入库），站点用的是裁剪后的小图。' -ForegroundColor Green
