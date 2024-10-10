# TeamViewer_MSI_Uninstall
Uninstall any version of TeamViewer MSI

This is mainly for TeamViewer Host.
If you want to uninstall TeamViewer from all devices in a company, and you find there are multiple different versions due to some installing updates and others not, then this will find the msi ID number of the currently installed version and uninstall it.
I had this issue because there was 600 devices with over 20 different versions to uninstall.

Run with following command: .\uninstall_teamviewer.ps1 /qn
