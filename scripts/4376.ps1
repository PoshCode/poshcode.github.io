$Computers = DATA {
  ConvertFrom-StringData -stringdata @'
    Server1 = 0E:A7:DE:AD:BE:EF
    Server2 = DE:AD:BE:EF:70:E5
'@
}

# You should have a .psd1 file matching the name of this script in a folder matching $PSCulture
# It should consist of a ConvertFrom-StringData statement like the one above
Import-LocalizedData -BindingVariable Computers -ErrorAction SilentlyContinue -ErrorVariable NotLocalized
if($NotLocalized) {
	Write-Warning "No Server list found. Using hard-coded default servers:"
	Write-Warning $NotLocalized[0]
}

#wakeonlan $computer
function Send-WakeOnLan
{
	#.Synopsis
	#   Wake a computer
	[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
	param(
		[Parameter(Mandatory=$true,ParameterSetName="MacAddress",ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,ValueFromRemainingArguments=$true)]
		[string[]]$Computer
	)


	# If the $Computer parameter is a computer name, and the name is in our data
	# Or is a MacAddress which is in our data
	# This will match it, and get the full information.
	# Otherwise, assume it's a MacAddress already
	$MacAddresses = foreach($c in $Computer) {
		if($output = foreach($pc in $Computers.GetEnumerator()) {
			if($pc.Key -like $c -or $pc.Value -eq $c) { 
				$pc.Value | Add-Member NoteProperty Name $pc.Name -Passthru
			}
		}) { $output } else { $c }
	}


	foreach($mac in $MacAddresses) {
		# Valid MacAddress has 6 pairs of hex characters (maybe separated by another character)
		$MacAddress = [regex]::Match($mac, '^(?:([0-9A-F]{2}).?){6}$')
		if(!$MacAddress.Success) {
			Write-Warning "$($mac.Name) $mac does not have a valid MacAddress. WakeOnLan skipped."
			continue
		}

	   if($PSCmdlet.ShouldProcess( "Waking the computer $mac $($mac.Name)",
	                               "Wake the computer $mac $($mac.Name)?",
	                               "Waking Computers" )) {

			$MacAddress = $MacAddress.Groups[1].Captures.Value | % { [byte]"0x$_" }

			$UDPclient = new-Object System.Net.Sockets.UdpClient
			$UDPclient.Connect(([System.Net.IPAddress]::Broadcast),4000)
			$packet = [byte[]](,0xFF * 102)
			6..101 |% { $packet[$_] = $mac[($_%6)]}
			$null = $UDPclient.Send($packet, $packet.Length)
		}
	}
}
