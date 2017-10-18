function Get-BogonList {
<#
	.SYNOPSIS
		Gets the bogon list.
	
	.DESCRIPTION
		The Get-BogonList function retrieves the bogon prefix list maintained by Team Cymru.
		
		A bogon prefix is a route that should never appear in the Internet routing table.
		A packet routed over the public Internet (not including over VPNs or other tunnels) should never have a source address in a bogon range.
		These are commonly found as the source addresses of DDoS attacks. Bogons are defined as Martians (private and reserved addresses defined by RFC 1918 and RFC 5735) and 
		netblocks that have not been allocated to a regional internet registry (RIR) by the Internet Assigned Numbers Authority.
		
	.PARAMETER Aggregated
		By default the unaggregated bogon list is retrieved. Use this switch parameter to retrieve the aggregated list.
	
	.OUTPUTS
		PSObject
	
	.EXAMPLE
		Get-BogonList
		Retrieves the unaggregated bogon list from Team Cymru.
		
	.EXAMPLE
		Get-BogonList -Aggregated
		Retrieves the aggregated bogon list from Team Cymru.
	
	.NOTES
		Name: Get-BogonList
		Author: Rich Kusak (rkusak@cbcag.edu)
		Created: 2010-01-31
		LastEdit: 2010-06-02 13:22
		Version: 1.1.0
		
		#Requires -Version 2.0
		
	.LINK
		http://www.team-cymru.org/Services/Bogons/

#>
	
	[CmdletBinding()]
	param (
		[switch]$Aggregated
	)
	
	# Create a web client object
	$webClient = New-Object System.Net.WebClient
	
	# Parse the bogons sites for the last updated date and current version
	$version = $webClient.DownloadString('http://www.team-cymru.org/Services/Bogons/') -split "`n" |
		Where-Object {$_ -match 'Bogons Last Updated:' -or $_ -match 'Current version:'} |
		ForEach-Object {$_.ToString().Replace('<strong>',"").Replace('</strong><br />',"").Trim()}
	
	# Display title and version information
	Write-Host "Team Cymru Bogon List" ; $version
	
	# Retrieve and display the aggregated bogon list
	if ($Aggregated) {
		foreach ($bogon in $webClient.DownloadString('http://www.team-cymru.org/Services/Bogons/bogon-bn-agg.txt') -split "`n") {
			New-Object PSObject -Property @{'Aggregated Bogons' = $bogon}
		}

	# Retrieve and display the unaggregated bogon list
	} else {
		foreach ($bogon in $webClient.DownloadString('http://www.team-cymru.org/Services/Bogons/bogon-bn-nonagg.txt') -split "`n") {
			New-Object PSObject -Property @{'Unaggregated Bogons' = $bogon}
		}
	}
}
