<#
.SYNOPSIS
    Uninstalls ShareX application silently.
.DESCRIPTION
    This script attempts to find and run the ShareX uninstaller in silent mode.
    It checks for the uninstaller in the default installation locations and provides feedback on the process.
.NOTES
    Version: 1.1
    Author: strongestgeek
#>

$uninstallerLocations = @(
    "$env:LOCALAPPDATA\Programs\ShareX\unins000.exe",
    "C:\Program Files\ShareX\unins000.exe"
)

$uninstallerFound = $false

foreach ($uninstaller in $uninstallerLocations) {
    if (Test-Path $uninstaller) {
        Write-Host "Uninstaller found: $uninstaller"
        Start-Process -FilePath $uninstaller -ArgumentList '/VERYSILENT', '/NORESTART' -WindowStyle Hidden
        Write-Host "Uninstalled ShareX"
        $uninstallerFound = $true
        break
    }
}

if (-not $uninstallerFound) {
    Write-Host "Uninstaller not found in any of the expected locations"
}