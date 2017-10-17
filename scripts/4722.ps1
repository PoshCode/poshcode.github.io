# GpupdateADcomputer
# Synopsis: Updates group policy on remote domain computer,(Can be modified easily to include all computers or a list.).
# Johnny Reel
# V1.0
# Requirements PowerShell v2.0 / Administrative rights on target(s).
# 
# Example: .\GpupdateAdComputer.ps1
# Use domain\credential when prompted.
# Output: Updating Policy...
# User Policy update has completed successfully.
# Computer Policy update has completed successfully.

Import-Module -Name ActiveDirectory

# Insert computer name in the quotes or modify to accept a list. Use -Filter * in place of 'Name -like "<computer>"' to update all domain computers. 

$cn = Get-ADComputer -Filter 'Name -like "<computer>"'
$cred = $User
$session = New-PSSession -ComputerName $cn.Name -Credential $cred
Invoke-Command -Session $session -ScriptBlock {gpupdate /force}
