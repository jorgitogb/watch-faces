<#
.SYNOPSIS
  Build a watch face module and install it on the watch over adb.
.EXAMPLE
  .\install.ps1                              # builds :simple-digital (debug)
  .\install.ps1 -Module simple-digital -Connect 192.168.1.50:41234
#>
param(
    [string]$Module = "terminal-themes",
    [string]$Connect = ""   # ip:port from Wireless debugging on the watch
)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$gradle = if (Test-Path ".\gradlew.bat") { ".\gradlew.bat" } else { "gradle" }
& $gradle ":${Module}:assembleDebug"
if ($LASTEXITCODE -ne 0) { throw "Gradle build failed" }

if ($Connect) {
    adb connect $Connect
    if ($LASTEXITCODE -ne 0) { throw "adb connect failed" }
}

$apk = Get-ChildItem "$Module\build\outputs\apk\debug\*.apk" | Select-Object -First 1
if (-not $apk) { throw "No APK found for $Module" }

adb install -r $apk.FullName
if ($LASTEXITCODE -ne 0) { throw "adb install failed" }

Write-Host "Installed $($apk.Name). On the watch: long-press the face -> + -> pick it."
