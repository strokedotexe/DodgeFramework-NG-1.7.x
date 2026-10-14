# Builds DodgeFramework.dll for Skyrim SE/AE including 1.7.x.
# Run from this directory: powershell -ExecutionPolicy Bypass -File .\build.ps1
$ErrorActionPreference = 'Stop'

if (-not $env:VCPKG_ROOT) {
    throw 'set VCPKG_ROOT to a vcpkg checkout that has been bootstrapped'
}
$vcpkgRoot = $env:VCPKG_ROOT

$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$vs = & $vswhere -latest -products * `
    -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    -property installationPath
if (-not $vs) { throw 'no Visual Studio install with the C++ toolset was found' }

$cmakeDir = "$vs\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin"
$ninjaDir = "$vs\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja"

Push-Location $PSScriptRoot
try {
    $vcvars = "$vs\VC\Auxiliary\Build\vcvars64.bat"
    # vcvars64 only exports into a cmd session, so run the whole build through one.
    # vcvars64 exports its own VCPKG_ROOT (the copy bundled with VS), so ours is set afterwards.
    $script = @"
call "$vcvars" >nul || exit /b 1
set PATH=$cmakeDir;$ninjaDir;%PATH%
set VCPKG_ROOT=$vcpkgRoot
cmake --preset release -DCMAKE_MAKE_PROGRAM="$ninjaDir\ninja.exe" || exit /b 1
cmake --build build\release || exit /b 1
"@
    $bat = Join-Path $env:TEMP 'dmco_build.bat'
    Set-Content -Path $bat -Value $script -Encoding ASCII
    # CMake writes its progress to stderr, which would otherwise trip ErrorActionPreference.
    $ErrorActionPreference = 'Continue'
    & cmd /c $bat
    $code = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if ($code -ne 0) { throw "build failed with exit code $code" }

    $dll = Join-Path $PSScriptRoot 'build\release\DodgeFramework.dll'
    if (-not (Test-Path $dll)) { throw "build reported success but $dll is missing" }

    Write-Host "`n=== BUILD OK ===" -ForegroundColor Green
    Get-Item $dll | Select-Object FullName, Length, LastWriteTime | Format-List
    Write-Host 'run .\package.ps1 to assemble dist/'
} finally {
    Pop-Location
}
