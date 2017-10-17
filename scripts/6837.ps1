$snapins = "vmware.vimautomation.core"
foreach ($snapin in $snapins){if (!(Get-PSSnapin $snapin -ErrorAction SilentlyContinue)){Add-PSSnapin $snapin}}

$vserver = "vmware vCenter Server"
$vNetwork = "General_Services"
$logfile = "d:\Scripts\log\vm.log"
$subnet = "255.255.255.128"

connect-viserver -Server $vserver
$vms = Get-VM
foreach ($vm in $vms){
	$nw = $vm|Get-NetworkAdapter
	if (($nw.networkname) -like $vNetwork){
		$NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -ComputerName $vm.name| where{$_.IPEnabled -eq “TRUE”}
		Foreach($NIC in $NICs) {
			try{
				$NIC.EnableStatic($nic.ipaddress, $subnet)
				$string = "$vm is adapted"
				$string 
				$string|Out-File -FilePath $logfile -Append -Encoding OEM
			}
			Catch{
				$string = "$vm is not adapted"
				$string 
				$string|Out-File -FilePath $logfile -Append -Encoding OEM
			}
		}
	}
}
