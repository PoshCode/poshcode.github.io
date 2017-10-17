

	Write-Host ""
	Write-Host "This is dangerous - beware!"
	Write-Host "Type: delssids client.domain.com to DELETE ALL it's SAVESETS!!"

	function delssids {
		## warning - no checks on first arg, security hole! ;)
		$client = $args[0]
		$ssids = (mminfo -av -q "client=$client" -r ssid)
		$ssids | ForEach-Object { nsrmm -d -S $_ -y }
		Write-Host "Done!"
	}

