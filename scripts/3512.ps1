#========================================================================
# Created on:   7/11/2012 3:59 PM
# Created by:   Clint Jones
# Organization: Virtually Genius!
# Filename:     Upgrade-VMToolsNoReboot
#========================================================================

Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer -Server <vi server> -Credential (Get-Credential)

$cluster = Read-Host "Cluster to upgrade:"

$oldTools = Get-Cluster $cluster | Get-VM | % {Get-View $_.ID} | Where {$_.guest.toolsstatus -match "toolsOld"}

foreach ($vm in $oldTools)
{
 Get-VMGuest $vm.Name | Update-Tools -NoReboot -RunAsync 
}
