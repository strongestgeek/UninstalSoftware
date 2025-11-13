# Uninstalls Firefox that is located in the user's local profile
# Function to detect and uninstall Firefox for each user profile
function Uninstall-UserFirefox {
    # Get all user profile directories from C:\Users
    $userProfiles = Get-ChildItem -Path "C:\Users" -Directory
    foreach ($userProfile in $userProfiles) {
        $userFoxPath = Join-Path -Path $userProfile.FullName -ChildPath "AppData\Local\Mozilla Firefox"
        $FoxExecutable = Join-Path -Path $userFoxPath -ChildPath "firefox.exe"
        # Check if firefox.exe exists, indicating it is installed in this user's profile
        if (Test-Path -Path $FoxExecutable) {
            # Look for any uninstaller file"
            $uninstaller = Get-ChildItem -Path $userFoxPath -Filter "uninstall\helper.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($uninstaller) {
                # Run the uninstaller in silent mode if found
                & $uninstaller.FullName -ArgumentList "/S" -Wait
                Start-Sleep -Seconds 5
            } else {  
            }
            # Check if the Folder folder still exists and delete it if present
            if (Test-Path -Path $userFoxPath) {
                Remove-Item -Recurse -Force -Path $userFoxPath
            } else {
            }
        } else {
        }
    }
}

Uninstall-UserFirefox
