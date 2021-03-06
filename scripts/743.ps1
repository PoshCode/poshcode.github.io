#requires -version 2.0 
# Author: Glenn Sizemore 12/19/2009
# Source: http://get-admin.com/blog/?p=239
#
# v1.0 	: It works
Cmdlet Update-vSwitchSecurity -SupportsShouldProcess {
	param (
	[Parameter(position=0,Mandatory=$TRUE,HelpMessage="Name of the vSwitch to modify")]
	[string]
	$vSwitch,

	[Parameter(position=1,Mandatory=$TRUE,ValueFromPipeline=$TRUE,HelpMessage="One or more hosts for which we want to modify the vSwitch Security")]
	[VMware.VimAutomation.Client20.VMHostImpl[]]
	$VMhost,

	[switch]
	$AllowPromiscuous,

	[switch]
	$MacChanges,

	[switch]
	$ForgedTransmits
	)
	#.Synopsis
	#   Modify the security settings of a vSwitch
	#.Description
	#   Modify the security settings of a vSwitch
	#.Parameter vSwitch
	#   Name of the vSwitch to modify
	#
	#	Type		: String
	#   Mandatory	: TRUE
	#	ParamaterSet: 
	#	PipeLine	: FALSE
	#.Parameter VMHost
	#   One or more hosts for which we want to modify the vSwitch Security
	#
	#	Type		: VMHostImpl[]
	#   Mandatory	: TRUE
	#	ParamaterSet: 
	#	PipeLine	: ByValue
	#.Parameter AllowPromiscuous
	#   If provided then AllowPromiscuous will be enabled thus allowing all traffic 
	#	is seen on the port.  The default action is to disable AllowPromiscuous.
	#
	#	Type		: String
	#   Mandatory	: TRUE
	#	ParamaterSet: 
	#	PipeLine	: FALSE
	#.Parameter ForgedTransmits
	#   If provided then ForgedTransmits will be enabled thus allowing the virtual
	#	network adapter to send network traffic with a different MAC address than 
	# 	that of the virtual network adapter. 
	#	The default action is to disable ForgedTransmits
	#
	#	Type		: Switch
	#   Mandatory	: FALSE
	#	ParamaterSet: 
	#	PipeLine	: FALSE
	#.Parameter MacChanges
	#   If provided then MacChanges will be enabled thus allowing Media Access Control
	#	(MAC) address to be changed. The default action is to disable MacChanges
	#
	#	Type		: Switch
	#   Mandatory	: FALSE
	#	ParamaterSet: 
	#	PipeLine	: FALSE
	#.Example
	#	# Set Promiscuous Mode, MAC Addess Changes, and Forged Transmits to reject.
	#   Update-vSwitchSecurity -VMHost (get-vmhost ESX1) -vSwitch 'vSwitch0'
	#.Example
	#	# Enable Promiscuous Mode on vSwitch1 on all ESX hosts in cluster SQL
	#
	#	Get-Cluster SQL | Get-VMHost | Update-vSwitchSecurity vswitch1 -AllowPromiscuous
	#
	#	# If your not sure your running against the correct host/switch use -whatif/confirm
	#	Get-Cluster SQL | Get-VMHost | Update-vSwitchSecurity vswitch1 -AllowPromiscuous -whatif
	#
	#	# Will output:
	#
	#	What if: Performing operation "Updating vSwitch1 Security settings: AllowPromiscuous=TRUE, 
	# 	MacChanges=FALSE, ForgedTransmits=FALSE" on Target "ESX1".
	#	What if: Performing operation "Updating vSwitch1 Security settings: AllowPromiscuous=TRUE,
	# 	MacChanges=FALSE, ForgedTransmits=FALSE" on Target "ESX2".
	#	What if: Performing operation "Updating vSwitch1 Security settings: AllowPromiscuous=TRUE,
	# 	MacChanges=FALSE, ForgedTransmits=FALSE" on Target "ESX3".
	#
	#   # Be aware that the vSwitch param will perform a wildcard search for the vswitch name!  	
	foreach ($H in $vmhost) {
		$hostid = Get-VMHost $H | get-view
		$networkSystem = get-view $hostid.ConfigManager.NetworkSystem
		$networkSystem.NetworkConfig.Vswitch| ?{$_.name -match $vSwitch} | % {
			$switchSpec = $_.spec
			$vSwitchName = $_.name
			if ($AllowPromiscuous) {
				$switchSpec.Policy.Security.AllowPromiscuous = $TRUE
				$msg = "Updating $($vSwitchName) Security settings: AllowPromiscuous=True"
			} else {
				$switchSpec.Policy.Security.AllowPromiscuous = $FALSE
				$msg = "Updating $($vSwitchName) Security settings: AllowPromiscuous=False"
			}
			if ($MacChanges) {
				$switchSpec.Policy.Security.MacChanges = $TRUE
				$msg += ", MacChanges=True"
			} else {
				$switchSpec.Policy.Security.MacChanges = $FALSE
				$msg += ", MacChanges=False"
			}
			if ($ForgedTransmits) {
				$switchSpec.Policy.Security.ForgedTransmits = $TRUE
				$msg += ", ForgedTransmits=True"
			} else {
				$switchSpec.Policy.Security.ForgedTransmits = $FALSE
				$msg += ", ForgedTransmits=False"
			}
			if (($pscmdlet.ShouldProcess($H.Name, $msg))) {
				$hostNetworkSystemView = get-view $hostid.configManager.networkSystem
				$hostNetworkSystemView.UpdateVirtualSwitch($vSwitchName, $switchSpec)
			}
		}
	}
}
