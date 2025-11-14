# minimal: run per-user uninstall helper.exe if present
$exclude = 'Public','Default','Default User','All Users'
Get-ChildItem 'C:\Users' -Directory |
  Where-Object { $exclude -notcontains $_.Name } |
  ForEach-Object {
    $user = $_.Name
    $helper = Join-Path $_.FullName 'AppData\Local\Mozilla Firefox\uninstall\helper.exe'
    if (Test-Path $helper) {
      Write-Output "Running helper.exe for user: $user -> $helper"
      try {
        Start-Process -FilePath $helper -ArgumentList '/S' -Wait -NoNewWindow -ErrorAction Stop
        Write-Output "Succeeded: $user"
      } catch {
        Write-Output "Failed to run helper.exe for $user $($_.Exception.Message)"
      }
    } else {
      Write-Output "No helper.exe for user: $user"
    }
  }
