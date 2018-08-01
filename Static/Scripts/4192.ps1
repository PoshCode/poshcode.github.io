Get-VM | Get-VMGuest | Where{$_.GuestId} | Where{$_.GuestId.contains("win") -and $_.State -eq 'Running'} | Update-Tools -NoReboot

