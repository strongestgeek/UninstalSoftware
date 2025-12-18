try {
    # 1. Remove the AppX package for all current users
    # We pipe directly to Remove-AppxPackage -AllUsers to handle all instances efficiently without a manual loop.
    $app = Get-AppxPackage -AllUsers -Name "Microsoft.M365Companions" -ErrorAction SilentlyContinue
    
    if ($app) {
        Write-Host "Found $($app.Count) instance(s) of Microsoft.M365Companions. Removing..."
        
        # We select unique PackageFullNames to avoid trying to remove the exact same version multiple times
        $app | Select-Object -ExpandProperty PackageFullName -Unique | ForEach-Object {
            Write-Host "Removing Package: $_"
            Remove-AppxPackage -Package $_ -AllUsers -ErrorAction Stop
        }
    } else {
        Write-Host "Microsoft.M365Companions not found on user profiles."
    }

    # 2. De-provision the AppX package to prevent reinstallation for new users
    $provisionedApp = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq "Microsoft.M365Companions" }
    
    if ($provisionedApp) {
        Write-Host "De-provisioning Microsoft.M365Companions from system image."
        # REMOVED: -AllUsers (Invalid parameter for this cmdlet)
        Remove-AppxProvisionedPackage -Online -PackageName $provisionedApp.PackageName -ErrorAction Stop
    } else {
        Write-Host "Microsoft.M365Companions not provisioned on the device."
    }

    Write-Host "Remediation completed successfully."
    exit 0

} catch {
    # This block will now trigger correctly because we used -ErrorAction Stop above
    Write-Host "Error during remediation: $($_.Exception.Message)"
    exit 1
}
