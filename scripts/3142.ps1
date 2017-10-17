function Remove-FTPFile ($Source,$UserName,$Password)
{
  #Create FTP Web Request Object to handle connnection to the FTP Server
  $ftprequest = [System.Net.FtpWebRequest]::Create($Source)
  
  # set the request's network credentials for an authenticated connection  
	$ftprequest.Credentials = New-Object System.Net.NetworkCredential($username,$password)
	
	$ftprequest.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
	
  # send the ftp request to the server  
	$ftpresponse = $ftprequest.GetResponse()  
	$ftpresponse
	
}
