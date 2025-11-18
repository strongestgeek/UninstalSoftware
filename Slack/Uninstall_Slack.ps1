$userProfiles = Get-ChildItem -Path 'C:\Users' -Directory

# Check for AppX package first
if (Get-AppxPackage -Name "*slack*") {
    Write-Output "Slack found as AppX package"
    Get-AppxPackage -AllUsers *slack* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
} else {
    Write-Host "Not found as AppX"
}

# Check each user profile for traditional installation
foreach ($user in $userProfiles) {
    $exe = Join-Path $user.FullName 'AppData\Local\slack\slack.exe'
    
    if (Test-Path $exe) {
        Write-Output "Found: $($user.Name) -> $exe"
        
        # Stop all Slack processes
        Get-Process -Name "slack*" -ErrorAction SilentlyContinue | Stop-Process -Force
        
        # Run uninstaller - Slack uses Update.exe for uninstall
        $updateExe = Join-Path $user.FullName 'AppData\Local\slack\Update.exe'
        
        if (Test-Path $updateExe) {
            Start-Process -Wait -FilePath $updateExe -ArgumentList "--uninstall", "-s" -NoNewWindow
            Write-Output "Uninstalled for user: $($user.Name)"
        } else {
            Write-Output "Update.exe not found for: $($user.Name)"
        }
        
    } else {
        Write-Output "Not found: $($user.Name)"
    }
}