#Requires -Version 5.1

<#
.SYNOPSIS
    Detection script for Adobe Acrobat Reader DC versions older than 25.001.20693
.DESCRIPTION
    Checks if any version of Adobe Acrobat Reader DC older than 25.001.20693 is installed
    Exit 0 = No old versions found (compliant)
    Exit 1 = Old versions found (non-compliant, triggers remediation)
#>

$targetVersion = [version]"25.001.20693"

try {
    # Search in both 32-bit and 64-bit registry paths
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    $oldVersionFound = $false
    
    foreach ($path in $registryPaths) {
        $apps = Get-ItemProperty $path -ErrorAction SilentlyContinue
        
        foreach ($app in $apps) {
            if ($app.DisplayName -like "*Adobe Acrobat Reader DC*" -or $app.DisplayName -like "*Adobe Acrobat Reader*") {
                
                # Extract version number
                $versionString = $app.DisplayVersion
                
                if ($versionString) {
                    # Parse version - Adobe uses format like "24.001.20615"
                    try {
                        $installedVersion = [version]$versionString
                        
                        if ($installedVersion -lt $targetVersion) {
                            $oldVersionFound = $true
                            break
                        }
                    }
                    catch {
                        # If version parsing fails, assume it's old to be safe
                        $oldVersionFound = $true
                        break
                    }
                }
            }
        }
        
        if ($oldVersionFound) { break }
    }
    
    if ($oldVersionFound) {
        Write-Output "Old version of Adobe Acrobat Reader DC found"
        exit 1  # Non-compliant, trigger remediation
    }
    else {
        Write-Output "No old versions found or already up to date"
        exit 0  # Compliant
    }
}
catch {
    Write-Output "Error during detection: $_"
    exit 1  # Trigger remediation on error to be safe
}