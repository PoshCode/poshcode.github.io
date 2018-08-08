########################################################
# Created by Brian English 
#   Brian.English@charlottefl.com
#   eddiephoenix@gmail.com
# 
# for Charlotte County Government
# No warranty suggested or implied
########################################################
# Purpose: Cycle through all VMs on a Virtualcenter Server
#          and update the 'SyncTimeWithHost' to either true or false
########################################################
# Notes:   VMware Tools must be installed on guest vm
########################################################

#################
$prodhost = "virtualcenter"
$devhost = "virtualtest"
#################


#############
###########
#

"1 Prod Hosts"
"2 Dev Hosts"
$hosts = read-host "What hosts to copy to"
switch($hosts)
{ "1"{$hosts = $prodhost}
  "2"{$hosts = $devhost}
}
get-esx $hosts


$swtch = read-host "Sync time to host yes/no"
switch($swtch)
{
  "yes"{$swtch = $true}
  "no"{$swtch = $false}
}

$vms = Get-VM 
foreach($vm in $vms)
{ 
  $view = get-view $vm.ID
  $config = $view.config
  $tools = $config.tools
  
  $spec = new-object VMware.Vim.VirtualMachineConfigSpec 
  $spec.tools = $tools
  $spec.tools.SyncTimeWithHost = $swtch
  
@@  #this line executes the update to VMTools
@@  $rslt = $view.ReconfigVM_task($spec)
  
  write-host ($vm.name + " " + $tools.SyncTimeWithHost)
}
