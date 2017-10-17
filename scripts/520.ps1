########################################################
# Created by Brian English
# for Charlotte County Government
# No warranty suggested or implied
########################################################

########################################################
#connect to VirtualCenter server (i.e. virtual-center-1)

if ($args[0] -eq $null)
{$hostName = Read-Host "What host do you want to connect to?"}
else
{$hostName = $args[0]}

#connect to selected Virtualcenter or host server
Connect-VIServer $hostName

########################################################
#get all vms listed in virtualcenter
$vms = get-vm

########################################################
#check power state on each vm
#if 'On' update tools

Foreach ($i in $vms) 
{ #if virtualcenter is virtualized skip it
  # a system restart would stop this script
  if ((get-vm -name $i).Name -eq $hostname)
  {"Skipping " + $hostname}
  #if primary DC or DNS is virtualized skip it too
  #elseif ((get-vm -name $i).Name -eq "DNS/DC/DHCP")
  #{"Skipping DNS/DC/DHCP server name"}
  else
  { 
    if ((get-vm -name $i).PowerState -eq "PoweredOn")
    { $i
      Get-Date -format "hh:mm:ss"
@@    update-tools -guest (get-vmguest -vm (get-vm -name $i))
      Get-Date -format "hh:mm:ss"
    }#if
  #}#if
}#foreach
