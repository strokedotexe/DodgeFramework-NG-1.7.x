<#
.SYNOPSIS
    Regenerates mcm/Translations from a set of upstream translation files.

.DESCRIPTION
    The files in mcm/Translations are the upstream Dodge Framework translations with the strings
    from new-strings.tsv appended. They are committed, so this script is only needed when the
    upstream files change or a new string is added. Skyrim requires these files to be UTF-16 LE
    with a BOM, which is why they are written through an explicit encoder.

.PARAMETER BaseDir
    Directory holding the upstream DodgeFramework_<language>.txt files, normally the
    Interface/Translations folder of an installed Dodge MCO-DXP.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$BaseDir
)

$ErrorActionPreference = 'Stop'

$outDir = Join-Path $PSScriptRoot 'Translations'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$utf16 = New-Object System.Text.UnicodeEncoding($false, $true)
$rows = [System.IO.File]::ReadAllLines((Join-Path $PSScriptRoot 'new-strings.tsv'), [System.Text.Encoding]::UTF8) |
    Where-Object { $_.Trim() } |
    ForEach-Object { , $_.Split("`t") }

foreach ($group in ($rows | Group-Object { $_[0] })) {
    $lang = $group.Name
    $src = Join-Path $BaseDir "DodgeFramework_$lang.txt"
    if (-not (Test-Path $src)) { Write-Warning "no upstream file for $lang"; continue }

    $text = [System.IO.File]::ReadAllText($src, [System.Text.Encoding]::Unicode).TrimEnd("`r", "`n")
    $added = 0
    $lines = foreach ($row in $group.Group) {
        if ($text -match [regex]::Escape($row[1])) { continue }
        $added++
        "$($row[1])`t$($row[2])"
    }

    $out = Join-Path $outDir "DodgeFramework_$lang.txt"
    [System.IO.File]::WriteAllText($out, ($text + "`r`n`r`n" + ($lines -join "`r`n") + "`r`n"), $utf16)
    Write-Host ("{0,-10} +{1} keys -> {2} bytes" -f $lang, $added, (Get-Item $out).Length)
}
