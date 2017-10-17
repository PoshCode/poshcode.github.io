# Script to fetch all FC adapter WWN's per Cluster
# By Leon Scheltema AVANCE ICT Groep Nederland

# Begin variables
$VC1 = ""
$cluster = ""
# End variables

# Connect to vCenter server
Connect-VIServer "$VC1"

$scope = Get-VMHost     # All hosts connected in vCenter
$scope = Get-Cluster -Name $cluster | Get-VMHost # All hosts in a specific cluster
foreach ($esx in $scope){
Write-Host "Host:", $esx
$hbas = Get-VMHostHba -VMHost $esx -Type FibreChannel
foreach ($hba in $hbas){
$wwpn = "{0:x}" -f $hba.PortWorldWideName
Write-Host `t $hba.Device, "|", $hba.model, "|", "World Wide Port Name:" $wwpn
}}

# Disconnect from vCenter server
Disconnect-VIServer -server "$VC1" -Force -Confirm:$false
