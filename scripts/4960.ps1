@@$check = Get-WindowsFeature | Where-Object {$_.Name -eq "SNMP-Service"}

If ($check.Installed -ne "True") {
	#Install/Enable SNMP Services
	Add-WindowsFeature SNMP-Service 
}

@@$check = Get-WindowsFeature | Where-Object {$_.Name -eq "SNMP-Service"}
