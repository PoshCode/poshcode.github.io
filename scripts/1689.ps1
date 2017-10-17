$cred = Get-Credential

[System.Net.FtpWebRequest]$request = [System.Net.WebRequest]::Create("ftp://joelbennett.net")
$request.Method = [System.Net.WebRequestMethods+FTP]::ListDirectory #Details
$request.Credentials = $cred

$response = $request.GetResponse()

$list = Receive-Stream $response.GetResponseStream()
