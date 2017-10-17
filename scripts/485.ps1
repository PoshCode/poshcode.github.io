get-vc vcservername
Get-VMHost | New-VirtualSwitch -Name SwitchName
Get-VMHost | Get-VirtualSwitch -Name SwitchName | New-VirtualPortGroup -Name portgroupname -VLANID vlan_number

