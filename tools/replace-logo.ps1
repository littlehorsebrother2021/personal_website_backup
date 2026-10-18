<#
replace-logo.ps1

Replace the hexo-theme-matery favicon and site logo with the PNG in
assets/. Files are copied byte-for-byte; the image is never read or
resized.

Usage:
  powershell -ExecutionPolicy Bypass -File tools\replace-logo.ps1 -Build

Options:
  -Source  PNG file to use, defaults to assets/logo.png
  -Build   run hexo clean && hexo generate afterwards
#>
param(
    [string]$Source,
    [switch]$Build
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
if (-not $Source) {
    $Source = Join-Path $root 'assets\logo.png'
}

$sourceFile = (Resolve-Path -LiteralPath $Source -ErrorAction Stop).Path
if ([System.IO.Path]::GetExtension($sourceFile) -ne '.png') {
    throw "Source must be a PNG file: $sourceFile"
}

$targets = @(
    (Join-Path $root 'themes\hexo-theme-matery\source\favicon.png'),
    (Join-Path $root 'themes\hexo-theme-matery\source\medias\logo.png'),
    (Join-Path $root 'public\favicon.png'),
    (Join-Path $root 'public\medias\logo.png')
)

Write-Output "Replacing favicon and logo with $sourceFile ..."
foreach ($target in $targets) {
    if (Test-Path -LiteralPath $target) {
        Copy-Item -LiteralPath $sourceFile -Destination $target -Force
        $sourceHash = (Get-FileHash -LiteralPath $sourceFile -Algorithm SHA256).Hash
        $targetHash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
        if ($sourceHash -ne $targetHash) {
            throw "Copy verification failed: $target"
        }
        Write-Output ("  Updated: {0}" -f $target)
    } else {
        Write-Output ("  Skipped (not found): {0}" -f $target)
    }
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
