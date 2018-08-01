# PG-duplex.ps1	: NIC Teaming with failover set on duplexity
# This script will configure the portgroup to use NIC Teaming where the failover is
# depending on the duplexity of the Active NIC.
#
# Parameters:
#	$esxName	: name of the ESX server
#	$vSwitch	: name of the vSwitch
#	$portgroup	: name of the portgroup
#	$actNIC		: active NICs array
#	$sbyNIC		: standby NICs array
#
# Author:	LucD
# History:
#	v1.0 27/08/09	first version
#

# Parameters
$esxName = "esx41.test.local"
$vSwitch = "vSwitch1"
$pgname = "Net1"
$actNIC = @("vmnic1")
$sbyNIC = @("vmnic2")

$esx = Get-VMHost $esxName | Get-View

# Check if vSwitch has Beacon Probing selected
$esx.Config.Network.Vswitch | where {$_.Name -eq $vSwitch} | %{
	if(-not $_.Spec.Policy.NicTeaming.FailureCriteria.CheckBeacon){
		"Beacon Probing should be enabled on the vSwitch first" | Out-Host
		exit
	}
}

$net = Get-View $esx.configmanager.networksystem
$portgroupspec = New-Object VMWare.Vim.HostPortGroupSpec
$portgroupSpec.vswitchname = $vSwitch
$portgroupspec.Name = $pgname
$portgroupspec.policy = New-object vmware.vim.HostNetworkPolicy

# NIC team
$portgroupspec.policy.NicTeaming = New-object vmware.vim.HostNicTeamingPolicy
$portgroupspec.policy.NicTeaming.nicOrder = New-Object vmware.vim.HostNicOrderPolicy
$portgroupspec.policy.NicTeaming.nicOrder.activeNic = $actNIC
$portgroupspec.policy.NicTeaming.nicOrder.standbyNic = $sbyNIC

# Failover Detection
$portgroupspec.policy.NicTeaming.failureCriteria = New-Object vmware.vim.HostNicFailureCriteria
$portgroupspec.policy.NicTeaming.failureCriteria.checkBeacon = $true

$portgroupspec.policy.NicTeaming.failureCriteria.checkDuplex = $true
$portgroupspec.policy.NicTeaming.failureCriteria.fullDuplex = "full"
$portgroupspec.policy.NicTeaming.failureCriteria.checkSpeed = "exact"
$portgroupspec.policy.NicTeaming.failureCriteria.speed = 1000

# Notify Switches
$portgroupspec.policy.NicTeaming.notifySwitches = $true

# Load Balancing
$portgroupspec.policy.NicTeaming.policy = "failover_explicit"

# Failback
$portgroupspec.policy.NicTeaming.RollingOrder = $false

$net.UpdatePortGroup($pgname, $PortGroupSpec)

