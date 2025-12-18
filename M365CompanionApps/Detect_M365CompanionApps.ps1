$App = Get-AppxPackage -AllUsers -Name "Microsoft.M365Companions" -ErrorAction SilentlyContinue
$Provisioned = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq "Microsoft.M365Companions" }

if ($null -ne $App -or $null -ne $Provisioned) {
    Write-Host "Microsoft 365 Companions found."
    exit 1 # Exit 1 tells Intune to run the Remediation script
} else {
    Write-Host "Not found."
    exit 0 # Exit 0 tells Intune the device is "Healthy"
}
