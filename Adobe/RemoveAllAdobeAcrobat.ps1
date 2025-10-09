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
        
        # Extract the product code from the uninstall string
        if ($UninstallString -match '\{[A-F0-9\-]+\}') {
            $productCode = $matches[0]
            Write-Output "Found product code: $productCode"
            
            # Use proper MSI uninstall with silent switches
            $arguments = "/x `"$productCode`" /qn /norestart REBOOT=ReallySuppress"
            
            Write-Output "Executing: msiexec.exe $arguments"
            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru -NoNewWindow -WindowStyle Hidden
            
            # Check exit code
            if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010 -or $process.ExitCode -eq 1605) {
                # 0 = success, 3010 = success but reboot required, 1605 = product not found (already uninstalled)
                Write-Output "Successfully uninstalled: $DisplayName (Version: $Version) - Exit Code: $($process.ExitCode)"
                return $true
            }
            else {
                Write-Output "Uninstall returned exit code $($process.ExitCode) for: $DisplayName"
                
                # If standard uninstall fails, try alternate method
                Write-Output "Attempting alternate uninstall method..."
                $arguments2 = "/x `"$productCode`" /quiet /norestart"
                $process2 = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments2 -Wait -PassThru -NoNewWindow -WindowStyle Hidden
                
                if ($process2.ExitCode -eq 0 -or $process2.ExitCode -eq 3010 -or $process2.ExitCode -eq 1605) {
                    Write-Output "Alternate method succeeded - Exit Code: $($process2.ExitCode)"
                    return $true
                }
                
                return $false
            }
        }
        else {
            Write-Output "Could not extract product code from uninstall string: $UninstallString"
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
    
    Write-Output "Found $($appsToUninstall.Count) old version(s) to uninstall"
    
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