# .SYNOPSIS
#	Print the hostname of the system.
# .DESCRIPTION
#	This function prints the hostname of the system. You can additionally output the DNS
#	domain or the FQDN by using the parameters as described below.
# .PARAMETER Short
#	(Default) Print only the computername, i.e. the same value as returned by $env:computername
# .PARAMETER Domain
#	If set, print only the DNS domain to which the system belongs. Overrides the Short parameter.
# .PARAMETER FQDN
#	If set, print the fully-qualified domain name (FQDN) of the system. Overrides the Domain parameter.

param (
	[switch]$Short		= $true,
	[switch]$Domain		= $false,
	[switch]$FQDN		= $false
)

$ipProperties = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()
if ( $FQDN ) {
	return "{0}.{1}" -f $ipProperties.HostName, $ipProperties.DomainName
}
if ( $Domain ) {
	return $ipProperties.DomainName
}
if ( $Short ) {
	return $ipProperties.HostName
}
