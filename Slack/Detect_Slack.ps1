$userProfiles = Get-ChildItem -Path 'C:\Users' -Directory
$exe = Join-Path $user.FullName 'AppData\Local\slack\slack.exe'

if (Get-AppxPackage -name com.tinyspeck.slackdesktop) {
    Exit 0
}   elseif (ForEach-Object ($user in $userProfiles)){
       if (Test-Path $exe) {
            Write-Output "Found: $($user.Name) -> $exe"
            EXit 0
        } else {
            Write-Output "Not found: $($user.Name)"
        }
        Exit 1
        }