
$headers = @{
	'Content-Type' = "application/x-www-form-urlencoded"
	'Accept' = "application/json"
	}

$response = Invoke-RestMethod -Uri $uri -Method POST -Header $headers -Credentail (Get-Credential)
