# start setting
# end setting

# User input ESXi host
$vCenter = Read-Host "Enter ESXi host FQDN"

# Connect VIserver
Connect-VIServer $vCenter

# Esxcli command pass-through to retrieve vmfs volume details
$esxcli=get-esxcli -vmhost $vCenter
$esxcli.storage.vmfs.extent.list() | ft volumename,VMFSUUID -autosize

# User input Location for persistent scratch location
$VolumeName = Read-Host "Enter Disk VolumeName"

# Get advanced setting and update value with user input
Get-AdvancedSetting -Entity (Get-VMhost -Name $vCenter) -Name "ScratchConfig.ConfiguredScratchLocation" | Set-AdvancedSetting -Value "/vmfs/volumes/$VolumeName" -Confirm:$False

# Disconnect VIserver
Disconnect-VIServer -Confirm:$false
