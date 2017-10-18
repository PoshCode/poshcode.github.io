# Set the VI Server and Filename before running
Connect-VIServer MYVISERVER
$filename = "C:\DetailedNetworkInfo.csv"

Write "Gathering VMHost objects"
$vmhosts = Get-VMHost | Sort Name | Where-Object {$_.State -eq "Connected"} | Get-View
$MyCol = @()
foreach ($vmhost in $vmhosts){
 $ESXHost = $vmhost.Name
 Write "Collating information for $ESXHost"
 $networkSystem = Get-view $vmhost.ConfigManager.NetworkSystem
 foreach($pnic in $networkSystem.NetworkConfig.Pnic){
     $pnicInfo = $networkSystem.QueryNetworkHint($pnic.Device)
     foreach($Hint in $pnicInfo){
         $NetworkInfo = "" | select-Object Host, vSwitch, vSwitchPorts, vSwitchPrtInUse, PNic, Speed, MAC, DeviceID, PortID, Observed, VLAN
         $NetworkInfo.Host = $vmhost.Name
		 $NetworkInfo.vSwitch = Get-Virtualswitch -VMHost (Get-VMHost ($vmhost.Name)) | where {$_.Nic -eq ($Hint.Device)}
         $NetworkInfo.vSwitchPorts = $NetworkInfo.vSwitch.NumPorts
		 $NetworkInfo.vSwitchPrtInUse = ($NetworkInfo.vSwitch.NumPorts - $NetworkInfo.vSwitch.NumPortsAvailable)
		 $NetworkInfo.PNic = $Hint.Device
         $NetworkInfo.DeviceID = $Hint.connectedSwitchPort.DevId
         $NetworkInfo.PortID = $Hint.connectedSwitchPort.PortId
         $record = 0
         Do{
             If ($Hint.Device -eq $vmhost.Config.Network.Pnic[$record].Device){
                 $NetworkInfo.Speed = $vmhost.Config.Network.Pnic[$record].LinkSpeed.SpeedMb
                 $NetworkInfo.MAC = $vmhost.Config.Network.Pnic[$record].Mac
             }
             $record ++
         }
         Until ($record -eq ($vmhost.Config.Network.Pnic.Length))
         foreach ($obs in $Hint.Subnet){
             $NetworkInfo.Observed += $obs.IpSubnet + " "
             Foreach ($VLAN in $obs.VlanId){
                 If ($VLAN -eq $null){
                 }
                 Else{
                     $strVLAN = $VLAN.ToString()
                     $NetworkInfo.VLAN += $strVLAN + " "
                 }
             }
         }
         $MyCol += $NetworkInfo
     }
 }
}
$Mycol | Sort Host, PNic | Export-Csv $filename -NoTypeInformation
