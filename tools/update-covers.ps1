<#
update-covers.ps1

Quickly replace the site banner images and article feature images for the
hexo-theme-matery theme. New images are center-cropped and resized to the
site's standard sizes so the pages do not show black bars.

Usage:
  powershell -ExecutionPolicy Bypass -File tools\update-covers.ps1 `
      -FeatureFolder .\assets\feature -BannerFolder .\assets\banner -Build

Options:
  -BannerFolder        folder with 7 images for the daily banner (Sun..Sat)
  -FeatureFolder       folder with the new article feature images
  -BannerWidth         banner output width, default 1280
  -BannerHeight        banner output height, default 720
  -FeatureWidth        feature output width, default 640
  -FeatureHeight       feature output height, default 426
  -NoResize            copy files as-is instead of resizing
  -Build               run hexo clean && hexo generate afterwards
#>
param(
    [string]$FeatureFolder,
    [string]$BannerFolder,
    [int]$BannerWidth = 1280,
    [int]$BannerHeight = 720,
    [int]$FeatureWidth = 640,
    [int]$FeatureHeight = 426,
    [switch]$NoResize,
    [switch]$Build
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$themeDir = Join-Path $root 'themes\hexo-theme-matery'
$bannerDir = Join-Path $themeDir 'source\medias\banner'
$featureDir = Join-Path $themeDir 'source\medias\featureimages'
$themeConfig = Join-Path $themeDir '_config.yml'

if (-not $FeatureFolder -and -not $BannerFolder) {
    throw 'Provide at least one of -FeatureFolder or -BannerFolder.'
}

function Resize-Cover {
    param(
        [string]$SourceFile,
        [string]$TargetFile,
        [int]$TargetWidth,
        [int]$TargetHeight
    )

    Add-Type -AssemblyName System.Drawing
    $src = [System.Drawing.Image]::FromFile($SourceFile)
    try {
        $scale = [Math]::Max($TargetWidth / $src.Width, $TargetHeight / $src.Height)
        $newW = [int][Math]::Ceiling($src.Width * $scale)
        $newH = [int][Math]::Ceiling($src.Height * $scale)

        $bmp = New-Object System.Drawing.Bitmap($TargetWidth, $TargetHeight)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        try {
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $srcRect = New-Object System.Drawing.Rectangle(0, 0, $src.Width, $src.Height)
            $dstRect = New-Object System.Drawing.Rectangle(
                -[int](($newW - $TargetWidth) / 2),
                -[int](($newH - $TargetHeight) / 2),
                $newW,
                $newH)
            $g.DrawImage($src, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
        } finally {
            $g.Dispose()
        }

        $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
            Where-Object { $_.MimeType -eq 'image/jpeg' }
        $params = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
            [System.Drawing.Imaging.Encoder]::Quality, [long]88)
        $bmp.Save($TargetFile, $codec, $params)
        $bmp.Dispose()
    } finally {
        $src.Dispose()
    }
}

function Copy-Numbered {
    param(
        [string]$SourceFolder,
        [string]$TargetFolder,
        [int]$TargetWidth,
        [int]$TargetHeight
    )

    if (-not (Test-Path -LiteralPath $SourceFolder)) {
        throw "Folder not found: $SourceFolder"
    }

    $files = Get-ChildItem -LiteralPath $SourceFolder -File |
        Where-Object { $_.Extension -in '.jpg', '.jpeg' } |
        Sort-Object Name

    if ($files.Count -eq 0) {
        throw "No .jpg/.jpeg images found in $SourceFolder"
    }

    New-Item -ItemType Directory -Force -Path $TargetFolder | Out-Null

    for ($i = 0; $i -lt $files.Count; $i++) {
        $target = Join-Path $TargetFolder "$i.jpg"
        if ($NoResize) {
            Copy-Item -LiteralPath $files[$i].FullName -Destination $target -Force
        } else {
            try {
                Resize-Cover -SourceFile $files[$i].FullName -TargetFile $target `
                    -TargetWidth $TargetWidth -TargetHeight $TargetHeight
            } catch {
                Write-Warning ("Resize failed for {0}, copied original instead: {1}" -f $files[$i].Name, $_.Exception.Message)
                Copy-Item -LiteralPath $files[$i].FullName -Destination $target -Force
            }
        }
        Write-Host ("  {0} <- {1}" -f "$i.jpg", $files[$i].Name)
    }

    return $files.Count
}

if ($BannerFolder) {
    Write-Output "[1/2] Updating banner images to ${BannerWidth}x${BannerHeight}..."
    $bannerCount = Copy-Numbered -SourceFolder $BannerFolder -TargetFolder $bannerDir `
        -TargetWidth $BannerWidth -TargetHeight $BannerHeight
    if ($bannerCount -lt 7) {
        Write-Warning "Banner folder has only $bannerCount images; the theme expects 7."
    }
    Write-Output "  Copied $bannerCount banner images."
}

if ($FeatureFolder) {
    Write-Output "[2/2] Updating feature images to ${FeatureWidth}x${FeatureHeight} and theme config..."
    $featureCount = Copy-Numbered -SourceFolder $FeatureFolder -TargetFolder $featureDir `
        -TargetWidth $FeatureWidth -TargetHeight $FeatureHeight

    $content = [System.IO.File]::ReadAllText($themeConfig)
    $pattern = '(?ms)^featureImages:\r?\n(?:- /medias/featureimages/\d+\.jpg\r?\n)+'
    if ($content -notmatch $pattern) {
        throw 'Could not locate the featureImages list in themes/hexo-theme-matery/_config.yml'
    }

    $nl = if ($content.Contains("`r`n")) { "`r`n" } else { "`n" }
    $list = (0..($featureCount - 1) | ForEach-Object { "- /medias/featureimages/$_.jpg" }) -join $nl
    $content = [regex]::Replace($content, $pattern, "featureImages:$nl$list$nl")
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($themeConfig, $content, $utf8NoBom)
    Write-Output "  Updated featureImages list with $featureCount images."
}

if ($Build) {
    Write-Output '[build] Running hexo clean && hexo generate...'
    $hexo = Join-Path $root 'node_modules\hexo\bin\hexo'
    & node $hexo clean
    if ($LASTEXITCODE -ne 0) { throw 'hexo clean failed' }
    & node $hexo generate
    if ($LASTEXITCODE -ne 0) { throw 'hexo generate failed' }
}

Write-Output 'Done.'
