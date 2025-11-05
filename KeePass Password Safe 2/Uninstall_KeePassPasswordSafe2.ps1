# "C:\Program Files (x86)\KeePass Password Safe 2\unins000.exe"
# KeePass EXE Version Remediation Script for Intune
# Exit 0 = Success
# Exit 1 = Failure

$uninstallerPath = "C:\Program Files (x86)\KeePass Password Safe 2\unins000.exe"
$keepassExePath = "C:\Program Files (x86)\KeePass Password Safe 2\KeePass.exe"

# Verify uninstaller exists
if (-not (Test-Path $uninstallerPath)) {
    Write-Output "Uninstaller not found at: $uninstallerPath"
    exit 1
}

# Check if KeePass process is running from the EXE installation path
$keepassProcesses = Get-Process -Name "KeePass" -ErrorAction SilentlyContinue

if ($keepassProcesses) {
    foreach ($process in $keepassProcesses) {
        try {
            $processPath = $process.Path
            # Only close the process if it's running from the EXE installation directory
            if ($processPath -like "C:\Program Files (x86)\KeePass Password Safe 2\*") {
                Write-Output "Closing KeePass process from EXE installation: $processPath"
                Stop-Process -Id $process.Id -Force
            }
        } catch {
            Write-Output "Could not determine path for process ID $($process.Id)"
        }
    }
    
    # Wait for process to fully terminate
    Start-Sleep -Seconds 3
}

# Run uninstaller silently
try {
    Write-Output "Starting silent uninstallation..."
    $uninstallProcess = Start-Process -FilePath $uninstallerPath -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait -PassThru
    
    if ($uninstallProcess.ExitCode -eq 0) {
        Write-Output "KeePass EXE version uninstalled successfully"
        exit 0
    } else {
        Write-Output "Uninstaller returned exit code: $($uninstallProcess.ExitCode)"
        exit 1
    }
} catch {
    Write-Output "Error during uninstallation: $_"
    exit 1
}