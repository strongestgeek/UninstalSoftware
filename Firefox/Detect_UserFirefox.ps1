# Function to detect Firefox for each user profile
function Get-UserFirefox {
    # Get all user profile directories from C:\Users
    $userProfiles = Get-ChildItem -Path "C:\Users" -Directory
    foreach ($userProfile in $userProfiles) {
        $userFoxPath = Join-Path -Path $userProfile.FullName -ChildPath "AppData\Local\Mozilla Firefox"
        $FoxExecutable = Join-Path -Path $userFoxPath -ChildPath "firefox.exe"
        # Check if firefox.exe exists, indicating it is installed in this user's profile
        if (Test-Path -Path $FoxExecutable) {
            # Look for any uninstaller file"
            Write-Host "Local User Firefox found."
            Exit 1
        } else {
            Write-Host "Local User Firefox not found."
            Exit 0
        }
    }
}


Get-UserFirefox 

