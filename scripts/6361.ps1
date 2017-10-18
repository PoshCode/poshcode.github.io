[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True)]
   [string]$magnetlink
)

#--------------------------------------------------------------------------
# replace the following items with your transmission remote settings
$addr="192.168.178.25"
$port="8111"
$user="admin"
$pass="admin"
#--------------------------------------------------------------------------

$uri="http://$($addr):$($port)/transmission/rpc"
$PWord = ConvertTo-SecureString –String $pass –AsPlainText -Force

# alternative to prompt for user/pass, use:
# $cred=Get-Credential
$cred = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $user, $PWord

try
{
	Invoke-RestMethod -Uri $uri -Credential $cred -ErrorAction SilentlyContinue
}
catch
{
}

$response=$error[0].ErrorDetails.Message
$sessionid=$response | Select-String -pattern 'X-Transmission-Session-Id\: (?<sessid>[a-zA-Z0-9]*)' | Foreach {$_.Matches.Groups[1].Value } 

#create body using backticks to escape double quotes
$body = "{`"method`":`"torrent-add`",`"arguments`":{`"filename`":`"$magnetlink`"}}"

Invoke-RestMethod -Uri $uri -Headers @{"X-Transmission-Session-Id"=$sessionid} -Credential $cred -Method Post -Body $body

