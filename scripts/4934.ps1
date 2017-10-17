# Script to set NTP / Syslog values for all ESXi hosts within a specific Cluster
# By Leon Scheltema AVANCE ICT Groep Nederland

# Begin variables
$VC1 = ""
$cluster = ""
$NTP = "ntp server 1","ntp server 2"
# End variables

# Connect to vCenter server
Connect-VIServer "$VC1"

$vmhosts = Get-Cluster $cluster | Get-VMhost

#Configure NTP server

foreach($vmhost in $vmhosts)
{
	Add-VmHostNtpServer -VMHost $vmhost -NtpServer $NTP
	#Allow NTP queries outbound through the firewall
	Get-VMHostFirewallException -VMHost $vmhost | where {$_.Name -eq "NTP client"} | Set-VMHostFirewallException -Enabled:$true
	#Start NTP client service and set to automatic
	Get-VmHostService -VMHost $vmhost | Where-Object {$_.key -eq "ntpd"} | Start-VMHostService
	Get-VmHostService -VMHost $vmhost | Where-Object {$_.key -eq "ntpd"} | Set-VMHostService -policy "automatic"
    #Set the Syslog LogHost
    Set-VMHostAdvancedConfiguration -Name Syslog.global.logHost -Value 'FQDN of SYSLOG HOST' -VMHost $vmhost
    #Use Get-EsxCli to restart the syslog service
    $esxcli = Get-EsxCli -VMHost $vmhost
    $esxcli.system.syslog.reload()
    #Open the firewall on the ESX Host to allow syslog traffic
    Get-VMHostFirewallException -Name "syslog" -VMHost $vmhost | set-VMHostFirewallException -Enabled:$true
}

# Disconnect from vCenter server
Disconnect-VIServer -server "$VC1" -Force -Confirm:$false

