#region << ePO Connection and Initialization >>
function McAfee-Connect{
	param([String]$script:ServerURL="SERVERNAME:8443")
	$c = McAfee-Credential
	$script:wc = McAfee-WebClient -Credential $c
}

function McAfee-Credential{
	$c = Get-Credential -Credential $null
	return $c
}

function McAfee-WebClient{
	param($Credential)
	$wc = new-object system.net.webclient
	$wc.credentials = New-Object System.Net.NetworkCredential -ArgumentList ($Credential.GetNetworkCredential().username,$Credential.GetNetworkCredential().password)
	return $wc
}
#endregion

