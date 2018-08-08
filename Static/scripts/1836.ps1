#Publish FF Entry using PowerShell script
#Description: PowerShell script to publish an entry to Friendfeed.
#Change the FF Username and Remotekey in the script.
#More info on the FF Api: http://friendfeed.com/api/
#Change the FF Username and Remotekey in the script.
#Author: Stefan Stranger
#Website: http://tinyurl.com/sstranger
#Date: 12/05/2010
#Version: 0.1

[System.Reflection.Assembly]::LoadWithPartialName(”System.Web") | Out-Null

Function Publish-FFEntry([string] $FFEntryText)
{ 
	[System.Net.ServicePointManager]::Expect100Continue = $false
	$request = [System.Net.WebRequest]::Create("http://friendfeed-api.com/v2/entry")
	$Username = "username"
	$Remotekey = "remotekey"
	$request.Credentials = new-object System.Net.NetworkCredential($Username, $Remotekey)
	$request.Method = "POST"
	$request.ContentType = "application/x-www-form-urlencoded" 
	write-progress "Publishing FF Entry" "Posting Entry" -cu $FFEntryText
	
	$formdata = [System.Text.Encoding]::UTF8.GetBytes( "body="  + $FFEntryText  )
	$requestStream = $request.GetRequestStream()
		$requestStream.Write($formdata, 0, $formdata.Length)
	$requestStream.Close()
	$response = $request.GetResponse()
	
	write-host $response.statuscode 
	$reader = new-object System.IO.StreamReader($response.GetResponseStream())
		$reader.ReadToEnd()
	$reader.Close()
}
#Author: Stefan Stranger
#Website: http://tinyurl.com/sstranger
#Date: 12/05/2010
#Version: 0.1

[System.Reflection.Assembly]::LoadWithPartialName(”System.Web") | Out-Null

Function Publish-FFEntry([string] $FFEntryText)
{ 
	[System.Net.ServicePointManager]::Expect100Continue = $false
	$request = [System.Net.WebRequest]::Create("http://friendfeed-api.com/v2/entry")
	$Username = "username"
	$Remotekey = "remotekey"
	$request.Credentials = new-object System.Net.NetworkCredential($Username, $Remotekey)
	$request.Method = "POST"
	$request.ContentType = "application/x-www-form-urlencoded" 
	write-progress "Publishing FF Entry" "Posting Entry" -cu $FFEntryText
	
	$formdata = [System.Text.Encoding]::UTF8.GetBytes( "body="  + $FFEntryText  )
	$requestStream = $request.GetRequestStream()
		$requestStream.Write($formdata, 0, $formdata.Length)
	$requestStream.Close()
	$response = $request.GetResponse()
	
	write-host $response.statuscode 
	$reader = new-object System.IO.StreamReader($response.GetResponseStream())
		$reader.ReadToEnd()
	$reader.Close()
}

Publish-FFentry "This entry is being published using a PowerShell script. Yabbadabadoo!!"

