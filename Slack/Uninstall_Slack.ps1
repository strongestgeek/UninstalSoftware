$userProfiles = Get-ChildItem -Path 'C:\Users' -Directory

# Check for AppX package first
if (Get-AppxPackage -Name com.tinyspeck.slackdesktop) {
    Write-Output "Slack found as AppX package"
    Get-AppxPackage -AllUsers *com.tinyspeck.slackdesktop* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
}   else {
    Write-Host "Not found as AppX"
}

# Check each user profile for traditional installation
foreach ($user in $userProfiles) {
    $exe = Join-Path $user.FullName 'AppData\Local\slack\slack.exe'
    if (Test-Path $exe) {
        Write-Output "Found: $($user.Name) -> $exe"
        Get-Process | Where-Object { $_.Name -eq "*slack*" } | Select-Object -First 1 | Stop-Process
        Start-Process -Wait -FilePath $exe -ArgumentList "--uninstall", "/S" -PassThru
    } else {
        Write-Output "Not found: $($user.Name)"
    }
}
