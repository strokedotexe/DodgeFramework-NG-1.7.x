<#
.SYNOPSIS
    Assembles dist/ into the layout a mod manager expects, and optionally zips it.

.PARAMETER Zip
    Also write dist/DodgeFramework-NG-<version>.zip, ready to upload.

.PARAMETER Symbols
    Include DodgeFramework.pdb. Useful for testers who report crash logs, too large for a
    normal release.
#>
[CmdletBinding()]
param(
    [switch]$Zip,
    [switch]$Symbols
)

$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$dist = Join-Path $root 'dist'
$built = Join-Path $root 'build\release\DodgeFramework.dll'

if (-not (Test-Path $built)) { throw "build first: $built does not exist" }

Remove-Item $dist -Recurse -Force -ErrorAction SilentlyContinue
foreach ($dir in 'SKSE\Plugins', 'MCM\Config\DodgeFramework', 'Interface\Translations') {
    New-Item -ItemType Directory -Force -Path (Join-Path $dist $dir) | Out-Null
}

Copy-Item $built (Join-Path $dist 'SKSE\Plugins')
if ($Symbols) { Copy-Item (Join-Path $root 'build\release\DodgeFramework.pdb') (Join-Path $dist 'SKSE\Plugins') }
Copy-Item (Join-Path $root 'mcm\Config\DodgeFramework\*') (Join-Path $dist 'MCM\Config\DodgeFramework')
Copy-Item (Join-Path $root 'mcm\Translations\*.txt') (Join-Path $dist 'Interface\Translations')

Get-ChildItem $dist -Recurse -File |
    ForEach-Object { '{0,-55} {1,9:N0}' -f $_.FullName.Substring($dist.Length + 1), $_.Length }

if ($Zip) {
    $version = (Select-String -Path (Join-Path $root 'CMakeLists.txt') -Pattern 'VERSION (\d+\.\d+\.\d+)').Matches[0].Groups[1].Value
    $archive = Join-Path $dist "DodgeFramework-NG-$version.zip"
    Compress-Archive -Path (Join-Path $dist '*') -DestinationPath $archive -Force
    Write-Host ''
    Write-Host ('{0}  {1:N0} bytes' -f $archive, (Get-Item $archive).Length)
}
