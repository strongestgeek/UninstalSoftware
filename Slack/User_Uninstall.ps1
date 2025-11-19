# 1. Stop Slack if it is running
Get-Process -Name "slack" -ErrorAction SilentlyContinue | Stop-Process -Force

# 2. Find and Remove the Slack MSIX Package
$SlackPackage = Get-AppxPackage | Where-Object {$_.Name -like "*Slack*"}

if ($SlackPackage) {
    Write-Host "Found Slack Package: $($SlackPackage.Name)" -ForegroundColor Cyan
    Write-Host "Removing AppxPackage..."
    Remove-AppxPackage -Package $SlackPackage.PackageFullName -ErrorAction Continue
    Write-Host "AppxPackage Removed." -ForegroundColor Green
} else {
    Write-Host "Slack AppxPackage not found (it might already be uninstalled)." -ForegroundColor Yellow
}

# 3. CLEANUP: Remove "Leftover" AppData Folders
# MSIX apps often leave data in these folders even after uninstallation.
$PathsToRemove = @(
    "$env:APPDATA\Slack",                        # Roaming Data
    "$env:LOCALAPPDATA\Slack",                   # Local Data
    "$env:LOCALAPPDATA\Packages\*Slack*"         # MSIX Container Data
)

Write-Host "Cleaning up AppData folders..."
foreach ($Path in $PathsToRemove) {
    # Handle wildcards for the 'Packages' folder
    $ExpandedPaths = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    
    # If it's a direct path without wildcards that exists
    if (Test-Path -Path $Path) { $ExpandedPaths = @($Path) }

    foreach ($Item in $ExpandedPaths) {
        try {
            Remove-Item -Path $Item -Recurse -Force -ErrorAction Stop
            Write-Host "Deleted: $Item" -ForegroundColor Green
        } catch {
            Write-Host "Could not delete: $Item (Check if file is in use)" -ForegroundColor Red
        }
    }
}

# 4. CLEANUP: Remove Registry Keys
# These keys often cause "older version installed" errors.
$RegKeys = @(
    "HKCU:\Software\Slack",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*Slack*"
)

Write-Host "Cleaning up Registry keys..."
foreach ($Key in $RegKeys) {
    if ($Key -like "*\**") {
        # Handle Wildcard Registry Search
        $Parent = Split-Path $Key -Parent
        $ChildMatch = Split-Path $Key -Leaf
        $FoundKeys = Get-ChildItem -Path $Parent -ErrorAction SilentlyContinue | Where-Object {$_.Name -like $ChildMatch}
        foreach ($k in $FoundKeys) {
            Remove-Item -Path $k.PSPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Registry Key Removed: $($k.Name)" -ForegroundColor Green
        }
    } elseif (Test-Path $Key) {
        Remove-Item -Path $Key -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Registry Key Removed: $Key" -ForegroundColor Green
    }
}

Write-Host "Cleanup Complete." -ForegroundColor Green
