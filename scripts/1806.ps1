# ahhh ... much better. Don't ask for prompts. It's not scriptable if you do.

function Set-IPAddress {
		param(	[string]$networkinterface,
			[string]$ip,
			[string]$mask,
			[string]$gateway,
			[string]$dns1,
			[string]$dns2,
			[string]$registerDns=$true
		 )
		$dns = $dns1
		if($dns2){$dns ="$dns1","$dns2"}
		$index = (gwmi Win32_NetworkAdapter | where {$_.netconnectionid -eq $networkinterface}).InterfaceIndex
		$NetInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.InterfaceIndex -eq $index}
		$NetInterface.EnableStatic($ip, $subnetmask)
		$NetInterface.SetGateways($gateway)
		$NetInterface.SetDNSServerSearchOrder($dns)
		$NetInterface.SetDynamicDNSRegistration($registerDns)
		
}
