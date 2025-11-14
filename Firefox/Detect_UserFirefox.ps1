# Get all user profile directories from C:\Users
$userProfiles = Get-ChildItem -Path "C:\Users" -Directory
foreach ($userProfile in $userProfiles) {
	$userFoxPath = Join-Path -Path $userProfile.FullName -ChildPath "AppData\Local\Mozilla Firefox"
	$FoxExecutable = Join-Path -Path $userFoxPath -ChildPath "firefox.exe"
	# Check if firefox.exe exists, indicating it is installed in this user's profile
	if (Test-Path -Path $FoxExecutable) {
		# Look for any uninstaller file"
		Write-Host $FoxExecutable
		Write-Host "Local User Firefox found."
		Write-Host "Exit 1."
		Exit 1
	} else {
		Write-Host "Local User Firefox not found."
		Write-Host "Exit 0."
		Exit 0
	}
} 
