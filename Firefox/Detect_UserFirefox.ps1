# simple check for firefox in all user profiles
$exclude = 'Public','Default','Default User','All Users'
$userProfiles = Get-ChildItem -Path 'C:\Users' -Directory |
                Where-Object { $exclude -notcontains $_.Name }

$found = $false

foreach ($user in $userProfiles) {
    $exe = Join-Path $user.FullName 'AppData\Local\Mozilla Firefox\firefox.exe'
    if (Test-Path $exe) {
        Write-Output "Found: $($user.Name) -> $exe"
        $found = $true
    } else {
        Write-Output "Not found: $($user.Name)"
    }
}

if ($found) {
    Write-Output 'At least one Firefox install was found.'
} else {
    Write-Output 'No Firefox installs found.'
}
