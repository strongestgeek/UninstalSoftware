$userProfiles = Get-ChildItem -Path 'C:\Users' -Directory
$found = $false

# Check for AppX package first
if (Get-AppxPackage -Name "*slack*") {
    Write-Output "Slack found as AppX package"
    Exit 0
}

# Check each user profile for traditional installation
foreach ($user in $userProfiles) {
    $exe = Join-Path $user.FullName 'AppData\Local\slack\slack.exe'
    
    if (Test-Path $exe) {
        Write-Output "Found: $($user.Name) -> $exe"
        $found = $true
        break  # Exit loop once found
    } else {
        Write-Output "Not found: $($user.Name)"
    }
}

if ($found) {
    Exit 0
} else {
    Exit 1
}