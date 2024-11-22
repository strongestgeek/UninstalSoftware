<#
    Manage-GitSystemInstallation.ps1

    Description:
    This script automates the management of Git installations on a Windows system. It:
    1. Detects and uninstalls user-specific Git installations from all user profiles.
    2. Removes associated Git registry keys from user-specific Windows registry hives.
    3. Installs Git system-wide in the default installation directory (`C:\Program Files\Git`).

    Usage:
    - Ensure that the path to the Git installer executable (`$gitInstallerPath`) is correct and accessible.
    - Run the script with elevated permissions (as Administrator) to manage files and registry entries across all users.
    - The script will uninstall Git installations from all user profiles, clean up registry entries, and install Git system-wide.

    Requirements:
    - Administrative privileges are required to access user profiles, registry entries, and system directories.
    - Ensure the Git installer executable supports silent installation parameters (`/VERYSILENT`, `/SUPPRESSMSGBOXES`, `/NORESTART`).

    Key Functions:
    - `Uninstall-UserGit`: Detects and removes Git installations in user profiles.
    - `Remove-GitRegistryKey`: Cleans up user-specific Git registry entries to prevent conflicts.
    - `Install-SystemGit`: Installs Git system-wide to a standard directory.

    Output:
    - Git installations are removed from user profiles, and a system-wide Git installation is completed. Logs and error messages will be displayed in the console.

    Notes:
    - Customize the `$systemInstallPath` and `$gitInstallerPath` variables if a different installation directory or installer is required.
    - Adjust the sleep intervals if necessary to accommodate system performance or uninstallation delays.
#>

# Define paths and log file for system-wide installation
$systemInstallPath = "C:\Program Files\Git"
$gitInstallerPath = ".\Git-2.47.0.2-64-bit.exe"

# Function to detect, uninstall, and clean up Git for each user profile
function Uninstall-UserGit {
    # Get all user profile directories from C:\Users
    $userProfiles = Get-ChildItem -Path "C:\Users" -Directory

    foreach ($userProfile in $userProfiles) {
        $userGitPath = Join-Path -Path $userProfile.FullName -ChildPath "AppData\Local\Programs\Git"
        $gitExecutable = Join-Path -Path $userGitPath -ChildPath "git-bash.exe"
        
        # Check if git-bash.exe exists, indicating Git is installed in this user's profile
        if (Test-Path -Path $gitExecutable) {
            
            # Look for any uninstaller file matching "unins*.exe"
            $uninstaller = Get-ChildItem -Path $userGitPath -Filter "unins*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1

            if ($uninstaller) {
                # Run the uninstaller in silent mode if found
                & $uninstaller.FullName /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
                Start-Sleep -Seconds 5
            } else {
            }
            
            # Check if the Git folder still exists and delete if present
            if (Test-Path -Path $userGitPath) {
                Remove-Item -Recurse -Force -Path $userGitPath
            } else {
            }
        } else {
        }
    }
}

# Function to delete the registry key if found
function Remove-GitRegistryKey {
    param (
        [string]$KeyPath = "Software\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1"
    )

    # Get all user profiles by accessing HKEY_USERS directly
    $hku = Get-ChildItem -Path "Registry::HKEY_USERS"

    foreach ($profile in $hku) {
        # Skip default profiles like .DEFAULT or system profiles
        if ($profile.PSChildName -notmatch "S-\d-\d+-\d+(-\d+)*") {
            continue
        }

        # Construct the full path to the target key
        $fullPath = "Registry::HKEY_USERS\$($profile.PSChildName)\$KeyPath"

        if (Test-Path $fullPath) {
            try {
                # Attempt to remove the registry key
                Remove-Item -Path $fullPath -Recurse -Force
            } catch {
            }
        } else {
        }
    }
}

# Function to install Git system-wide
function Install-SystemGit {

    # Clean up old installation if it exists
    if (Test-Path $systemInstallPath) {
        Remove-Item -Recurse -Force $systemInstallPath
    }

    # Start process with logging and wait for it to complete
    Start-Process -FilePath $gitInstallerPath /VERYSILENT, "/SUPPRESSMSGBOXES", "/NORESTART" -Wait

    # Check if installation was successful
    if (Test-Path "$systemInstallPath\git-bash.exe") {
    } else {
    }
}

# Run uninstall for each user profile
Uninstall-UserGit

# Run the function to remove the key
Remove-GitRegistryKey

# Wait briefly before installing system-wide
Start-Sleep -Seconds 5

# Run system-wide installation
Install-SystemGit
