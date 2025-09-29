<#
.SYNOPSIS
    Uninstalls ShareX application silently.
.DESCRIPTION
    This script attempts to find and run the ShareX uninstaller in silent mode.
    It checks for the uninstaller in multiple possible installation locations,
    accounting for both per-user and machine-wide installations.
    The script handles both SYSTEM and user contexts for Intune deployments.
.NOTES
    Version: 1.2
    Author: strongestgeek
#>

# Get all user profiles to check for per-user installations
$userProfiles = Get-ChildItem "C:\Users" -Directory | Where-Object { $_.Name -notin @('Public', 'Default', 'Default User', 'All Users') }

$uninstallerLocations = @(
    "C:\Program Files\ShareX\unins000.exe"  # Machine-wide installation
)

# Add per-user installation paths
foreach ($profile in $userProfiles) {
    $uninstallerLocations += Join-Path -Path $profile.FullName -ChildPath "AppData\Local\Programs\ShareX\unins000.exe"
}

$uninstallerFound = $false

foreach ($uninstaller in $uninstallerLocations) {
    if (Test-Path $uninstaller) {
        Write-Host "Uninstaller found: $uninstaller"
        try {
            Start-Process -FilePath $uninstaller -ArgumentList '/VERYSILENT', '/NORESTART' -WindowStyle Hidden -Wait
            Write-Host "Successfully uninstalled ShareX from: $uninstaller"
            $uninstallerFound = $true
        }
        catch {
            Write-Host "Error running uninstaller at $uninstaller : $_"
        }
    }
}

if (-not $uninstallerFound) {
    Write-Host "Uninstaller not found in any of the expected locations"
    exit 1
}
else {
    exit 0
}