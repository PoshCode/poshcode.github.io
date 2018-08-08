filter Select-Alive {
	param ( [switch]$Verbose )
	trap {
		Write-Verbose "$(get-date -f 's') ping failed: $computer"
		continue
	}
	if ($Verbose) {
		$VerbosePreference = "continue"
		$ErrorActionPreference = "continue"
	}
	else {
		$VerbosePreference = "silentlycontinue"
		$ErrorActionPreference = "silentlycontinue"
	}
	Write-Verbose "$(get-date -f 's') ping start"
	$ping = New-Object System.Net.NetworkInformation.Ping
	$reply = $null
	$_ | foreach-object {
		$obj = $_
		# Accomodate different input object types
		# thx Gaurhoth (http://thepowershellguy.com/blogs/gaurhoth/archive/2007/10/08/an-example-of-how-to-use-new-taskpool.aspx)
		switch ($obj.psbase.gettype().name) {
			"DirectoryEntry"    { $cn = $obj.dnshostname[0] }
			"IPHostEntry"		{ $cn = $obj.HostName }
			"PSCustomObject"    { $cn = $obj.Name }
			"SearchResult"      { $cn = $obj.properties['dnshostname'][0] }
			"String"            { $cn = $obj.trim() }
		}
		Write-Verbose "$(get-date -f 's') pinging $cn..."
		$searchCount++
		$reply = $ping.Send($cn)
		if ($reply.status -eq "Success") {
			$cn; $pingCount++
		}
	}
	Write-Verbose "$(get-date -f 's') ping end - $pingCount/$searchCount online"
}
