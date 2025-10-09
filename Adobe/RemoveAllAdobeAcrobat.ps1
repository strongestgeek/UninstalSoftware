#Requires -Version 5.1

<#
.SYNOPSIS
    Remediation script to uninstall Adobe Acrobat Reader DC versions older than 25.001.20693
.DESCRIPTION
    Silently uninstalls old versions of Adobe Acrobat Reader DC and verifies removal
    Exit 0 = Successfully uninstalled
    Exit 1 = Failed to uninstall
#>

$targetVersion = [version]"25.001.20693"

function Stop-AdobeProcesses {
    $processNames = @("AcroRd32", "Acrobat", "AdobeARM", "AdobeARMHelper", "AcrobatInfo")
    
    foreach ($proc in $processNames) {
        $processes = Get-Process -Name $proc -ErrorAction SilentlyContinue
        if ($processes) {
            $processes | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }
    }
}

function Uninstall-AdobeReader {
    param (
        [string]$UninstallString,
        [string]$DisplayName,
        [string]$Version
    )
    
    try {
        # Stop Adobe processes
        Stop-AdobeProcesses
        
        # Parse the uninstall string
        if ($UninstallString -match '^"(.+?)"(.*)$') {
            $exePath = $matches[1]
            $existingArgs = $matches[2].Trim()
        }
        elseif ($UninstallString -match '^(\S+)(.*)$') {
            $exePath = $matches[1]
            $existingArgs = $matches[2].Trim()
        }
        else {
            Write-Output "Could not parse uninstall string: $UninstallString"
            return $false
        }
        
        # Build silent uninstall arguments
        if ($UninstallString -like "*msiexec*") {
            # MSI-based uninstall
            $productCode = ($UninstallString -split " ")[1]
            $arguments = "/x $productCode /qn /norestart"
            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru -NoNewWindow
        }
        else {
            # EXE-based uninstall - use Adobe's silent switches
            $arguments = "/sAll /rs /msi REBOOT=ReallySuppress /qn /norestart"
            
            if (-not (Test-Path $exePath)) {
                Write-Output "Uninstaller not found: $exePath"
                return $false
            }
            
            $process = Start-Process -FilePath $exePath -ArgumentList $arguments -Wait -PassThru -NoNewWindow
        }
        
        # Check exit code
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            Write-Output "Successfully uninstalled: $DisplayName (Version: $Version)"
            return $true
        }
        else {
            Write-Output "Uninstall returned exit code $($process.ExitCode) for: $DisplayName"
            return $false
        }
    }
    catch {
        Write-Output "Error uninstalling ${DisplayName}: $_"
        return $false
    }
}

try {
    # Search in both 32-bit and 64-bit registry paths
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    $uninstalled = $false
    $appsToUninstall = @()
    
    # Find all old versions
    foreach ($path in $registryPaths) {
        $apps = Get-ItemProperty $path -ErrorAction SilentlyContinue
        
        foreach ($app in $apps) {
            if ($app.DisplayName -like "*Adobe Acrobat Reader DC*" -or $app.DisplayName -like "*Adobe Acrobat Reader*") {
                
                $versionString = $app.DisplayVersion
                $uninstallString = $app.UninstallString
                
                if ($versionString -and $uninstallString) {
                    try {
                        $installedVersion = [version]$versionString
                        
                        if ($installedVersion -lt $targetVersion) {
                            $appsToUninstall += @{
                                DisplayName = $app.DisplayName
                                Version = $versionString
                                UninstallString = $uninstallString
                            }
                        }
                    }
                    catch {
                        # If version parsing fails, add to uninstall list to be safe
                        $appsToUninstall += @{
                            DisplayName = $app.DisplayName
                            Version = $versionString
                            UninstallString = $uninstallString
                        }
                    }
                }
            }
        }
    }
    
    # Uninstall each old version found
    if ($appsToUninstall.Count -eq 0) {
        Write-Output "No old versions found to uninstall"
        exit 0
    }
    
    foreach ($app in $appsToUninstall) {
        Write-Output "Attempting to uninstall: $($app.DisplayName) - Version: $($app.Version)"
        $result = Uninstall-AdobeReader -UninstallString $app.UninstallString -DisplayName $app.DisplayName -Version $app.Version
        
        if ($result) {
            $uninstalled = $true
        }
    }
    
    # Wait a moment for registry to update
    Start-Sleep -Seconds 5
    
    # Verify uninstallation
    $stillInstalled = $false
    foreach ($path in $registryPaths) {
        $apps = Get-ItemProperty $path -ErrorAction SilentlyContinue
        
        foreach ($app in $apps) {
            if ($app.DisplayName -like "*Adobe Acrobat Reader DC*" -or $app.DisplayName -like "*Adobe Acrobat Reader*") {
                
                $versionString = $app.DisplayVersion
                
                if ($versionString) {
                    try {
                        $installedVersion = [version]$versionString
                        
                        if ($installedVersion -lt $targetVersion) {
                            $stillInstalled = $true
                            Write-Output "Verification failed: Old version still present - $($app.DisplayName) ($versionString)"
                        }
                    }
                    catch {
                        $stillInstalled = $true
                    }
                }
            }
        }
    }
    
    if ($stillInstalled) {
        Write-Output "Remediation failed: Old versions still detected after uninstall attempt"
        exit 1
    }
    else {
        Write-Output "Remediation successful: All old versions removed"
        exit 0
    }
}
catch {
    Write-Output "Error during remediation: $_"
    exit 1
}
