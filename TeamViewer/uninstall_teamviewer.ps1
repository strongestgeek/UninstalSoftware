# Find MSI Product Code
$teamviewerHost = Get-CimInstance -Query "SELECT * FROM Win32_Product WHERE Name = 'TeamViewer Host'"
$msiCode = $teamviewerHost.IdentifyingNumber

# Uninstall the application using the MSI Product Code
$uninstallCommand = "msiexec.exe /x $msiCode /qn"
Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallCommand" -WindowStyle Hidden