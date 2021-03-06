function Send-XMLFile ($Path, $IP, $Username, $Password)
{
	[Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }
	if (!(Test-Path $Path\SSP.XML))
	{
		Write-Error "No file found in directory exiting script"
	}
	
	else
	{
		$Filename = Get-Childitem $Path\SSP.XML -File | Select-Object Name, FullName
		Write-Output $Filename.FullName | Out-Null
		$FTP = [System.Net.FTPWebRequest]::Create("FTP://$IP/" + $Filename.Name)
		$FTP = [System.Net.FTPWebRequest]$FTP
		$FTP.UsePassive = $True
		$FTP.UseBinary = $True
		$FTP.EnableSsl = $True
		$FTP.Credentials = New-Object System.Net.NetworkCredential($Username, $Password)
		$FTP.Method = [System.Net.WebRequestMethods+FTP]::UploadFile
		$RS = $FTP.GetRequestStream()
		
		$Reader = New-Object System.IO.FileStream ($Filename.FullName, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
		[byte[]]$Buffer = New-Object byte[] 4096
		[int]$Count = 0
		do
		{
			$Count = $Reader.Read($Buffer, 0, $Buffer.Length)
			$RS.Write($Buffer, 0, $Count)
		}
		while ($Count -gt 0)
		$Reader.Close()
		$RS.Close()
	}
}

function Verify-XMLFileUpload($Username, $Password, $FTP_URI, $SubFolder)
{
	try
	{
		$FTP_URIX = $FTP_URI + $SubFolder
		$URI = [System.URI]$FTP_URIX
		$Encoding = [System.Text.Encoding]::GetEncoding(28591) #Set Encoding To ISO-8859-1 (Westeuropean ISO)
		[Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }
		$FTP = [System.Net.FTPWebRequest]::Create($URI)
		$FTP.Credentials = New-Object System.Net.NetworkCredential($Username, $Password)
		$FTP.Method = [system.Net.WebRequestMethods+FTP]::ListDirectoryDetails
		$FTP.UsePassive = $True
		$FTP.UseBinary = $True
		$FTP.EnableSsl = $True
		$Response = $FTP.GetResponse()
		$Strm = $Response.GetResponseStream()
		$Reader = New-Object System.IO.StreamReader($Strm, $Encoding)
		$List = $Reader.ReadToEnd()
		$Reader.Close | Out-Null
	}
	catch [System.InvalidOperationException]
	{
		throw "GetResponse or BeginGetResponse was used more than once OR EnableSSL was set to True but the server does not support this feature."
	}
}


# Execute like this

Send-XMLFile -IP "10.0.0.1" -Password $Pass -Username "redyey" -Path "C:\toupload"
Verify-XMLFileUpload -Username "redyey" -Password $Pass -FTP_URI FTP://10.0.0.1/ -subfolder /
