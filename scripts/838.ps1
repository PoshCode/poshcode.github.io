filter global:get-firewallstatus2 ([string]$computer = $env:computername)
	{
	if ($_) { $computer = $_ }

	$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine",$computer)

	$firewallEnabled = $reg.OpenSubKey("System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile").GetValue("EnableFirewall")

	[bool]$firewallEnabled
	}
