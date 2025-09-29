<#
.SYNOPSIS
    Uninstalls ShareX application silently.
.DESCRIPTION
    This script attempts to find and run the ShareX uninstaller in silent mode.
    It checks for the uninstaller in the default installation location and provides feedback on the process.
.NOTES
    Version: 1.0
    Author: strongestgeek
#>

$uninstaller = "$env:LOCALAPPDATA\Programs\ShareX\unins000.exe"
if (Test-Path $uninstaller) {
    Write-Host "Uninstaller found: $uninstaller"
    Start-Process -FilePath $uninstaller -ArgumentList '/VERYSILENT', '/NORESTART' -WindowStyle Hidden
    Write-Host "Uninstalled ShareX"
} else {
    Write-Host "Uninstaller not found"
}