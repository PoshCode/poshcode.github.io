function Set-IPAddress {
		param(	[switch]$help,
				[string]$networkinterface =$(read-host "Enter the name of the NIC (ie Local Area Connection)"),
				[string]$ip = $(read-host "Enter an IP Address (ie 10.10.10.10)"),
				[string]$mask = $(read-host "Enter the subnet mask (ie 255.255.255.0)"),
				[string]$gateway = $(read-host "Enter the current name of the NIC you want to rename"),
				[string]$dns1 = $(read-host "Enter the first DNS Server (ie 10.2.0.28)"),
				[string]$dns2,
				[string]$registerDns = "TRUE"
		 )
		
		$usage = "A help message goes here with an example of how to use the function `n"
		$usage += "You can add more to the help message here, but be sure to use the backtick n at the end"
		
		if ($help) {Write-Host $usage}
		
		#Start writing code here
		$dns = $dns1
		if($dns2){$dns ="$dns1,$dns2"}
		$index = (gwmi Win32_NetworkAdapter | where {$_.netconnectionid -eq $networkinterface}).InterfaceIndex
		$NetInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.InterfaceIndex -eq $index}
		$NetInterface.EnableStatic($ip, $subnetmask)
		$NetInterface.SetGateways($gateway)
		$NetInterface.SetDNSServerSearchOrder($dns)
		$NetInterface.SetDynamicDNSRegistration($registerDns)
		
}
