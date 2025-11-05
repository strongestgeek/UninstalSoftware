# KeePass EXE Version Detection Script for Intune
# Exit 0 = Compliant (EXE version not found)
# Exit 1 = Non-compliant (EXE version found, remediation needed)

$uninstallerPath = "C:\Program Files (x86)\KeePass Password Safe 2\unins000.exe"

if (Test-Path $uninstallerPath) {
    Write-Output "KeePass EXE version detected at: $uninstallerPath"
    exit 1
} else {
    Write-Output "KeePass EXE version not found - compliant"
    exit 0
}
