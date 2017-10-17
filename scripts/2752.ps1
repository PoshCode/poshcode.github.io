function set-vSwitchLinkDiscovery {
    Param (
        #Switch to enable vSwitch Discovery On
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)] [string] $vSwitchName = "vSwitch0",
        #Host on which the vSwitch Resides
        [Parameter(Mandatory=$true,HelpMessage="Need Host Name to connect with")] [string] $VMHost = "NoHostPassed"
    ) #Param

	PROCESS{ 
    #Variables
	$linkProtocol = "cdp"
	$linkOperation = "both"


	#Get the specification for the vSwitch
	$networkview = (get-vmhostnetwork -vmhost $VMHost | get-view)
	$vSwitchSpec = ($networkView.NetworkConfig.vSwitch | Where {$_.Name -eq $vSwitchName}).Spec

	#Set Protocol Type and Operation
	$vSwitchSpec.Bridge.LinkDiscoveryProtocolConfig.protocol = $linkProtocol	
    $vSwitchSpec.Bridge.LinkDiscoveryProtocolConfig.operation = $linkOperation

	#Commit Changes
	$networkview.updateVirtualSwitch($vSwitchName,$vSwitchSpec)
    "Updated " + $VMHost + "'s virtual switch " + $vSwitchName + " to do CDP"
         }
}
