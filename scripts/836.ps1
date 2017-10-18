# returns true if windows firewall is enabled, false if it is disabled
filter global:get-firewallstatus ([string]$computer = $env:computername)
	{
	if ($_) { $computer = $_ }

	$HKLM = 2147483650

	$reg = get-wmiobject -list -namespace root\default -computer $computer | where-object { $_.name -eq "StdRegProv" }
	$firewallEnabled = $reg.GetDwordValue($HKLM, "System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile","EnableFirewall")

	[bool]($firewallEnabled.uValue)
	}
