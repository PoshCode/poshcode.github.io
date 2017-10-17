function Set-Domain {
	param(	[switch]$help,
			[string]$domain=$(read-host "Please specify the domain to join"),
			[System.Management.Automation.PSCredential]$credential = $(Get-Credential) 
			)
			
	$usage = "`$cred = get-credential `n"
	$usage += "Set-AvaDomain -domain corp.avanade.org -credential `$cred`n"
	if ($help) {Write-Host $usage;exit}
	
	$username = $credential.GetNetworkCredential().UserName
	$password = $credential.GetNetworkCredential().Password
	$computer = Get-WmiObject Win32_ComputerSystem
	$computer.JoinDomainOrWorkGroup($domain ,$password, $username, $null, 3)
	
	}
