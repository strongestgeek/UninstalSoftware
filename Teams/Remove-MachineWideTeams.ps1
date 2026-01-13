# PowerShell Script to Uninstall Teams Machine-Wide Installer
# This safely ignores "New Teams" and "Classic Teams" user-apps, targeting only the System MSI.

$ErrorActionPreference = "SilentlyContinue"
$AppName = "Teams Machine-Wide Installer"

# 1. Define Registry Paths to search (Both 64-bit and 32-bit hives)
$RegPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

# 2. Search for the specific application
Write-Host "Searching for '$AppName'..."
$UninstallKeys = Get-ChildItem -Path $RegPaths -Recurse | Get-ItemProperty | Where-Object { $_.DisplayName -eq $AppName }

# 3. Process the uninstall
if ($UninstallKeys) {
    foreach ($Key in $UninstallKeys) {
        $Guid = $Key.PSChildName
        Write-Host "Found $AppName with GUID: $Guid"
        
        # Execute MSI Removal
        $Arguments = "/x $Guid /qn"
        Write-Host "Executing: msiexec.exe $Arguments"
        Start-Process "msiexec.exe" -ArgumentList $Arguments -Wait -NoNewWindow
        
        Write-Host "Successfully uninstalled $AppName."
    }
} else {
    Write-Host "$AppName not found on this device."
}
