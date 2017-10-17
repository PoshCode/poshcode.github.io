function set-vSwitchLinkDiscovery {
    Param (
        #Switch to enable vSwitch Discovery On
         [Parameter(Mandatory=$true,ValueFromPipeline=$true)]$vSwitchName
        #Host on which the vSwitch Resides
        ,[Parameter(Mandatory=$true,HelpMessage="")][string]$VMBackupDestination,
    ) #Param

	#Variables
	$vSwitchName = "vSwitch0"
	$linkProtocol = "cdp"
	$linkOperation = "both"
	$VMHost = "myhost"

	#Get the specification for the vSwitch
	$networkview = (get-vmhostnetwork -vmhost $VMHost | get-view)
	$vSwitchSpec = ($networkView.NetworkConfig.vSwitch | Where {$_.Name -eq $vSwitchName}).Spec

	#Set Protocol Type and Operation
	$vSwitchSpec.Bridge.LinkDiscoveryProtocolConfig.protocol = $linkProtocol	$vSwitchSpec.Bridge.LinkDiscoveryProtocolConfig.operation = $linkOperation

	#Commit Changes
	$networkview.updateVirtualSwitch($vSwitchName,$vSwitchSpec)
} 
