function Test-WebDav ()
{
	param ( $Url = "$( throw 'URL parameter is required.')" )
	$xhttp = New-Object -ComObject msxml2.xmlhttp
	$xhttp.open("OPTIONS", $url, $false)
	$xhttp.send()
	if ( $xhttp.getResponseHeader("DAV") ) { $true }
	else { $false }
}
