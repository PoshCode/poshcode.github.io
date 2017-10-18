Function Get-ShortURL {
	Param($longURL, $login, $apiKey)	
	$url = "http://api.bit.ly/shorten?version=2.0.1&format=xml&longUrl=$longURL&login=$login&apiKey=$apikey"
	$request = [net.webrequest]::Create($url)
	$responseStream = new-object System.IO.StreamReader($request.GetResponse().GetResponseStream())
	$response = $responseStream.ReadToEnd()
	$responseStream.Close()
	
	$result = [xml]$response
	Write-Output $result.bitly.results.nodeKeyVal.shortUrl
}
