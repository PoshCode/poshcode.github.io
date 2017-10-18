$ewsPath = "C:\Program Files\Microsoft\Exchange\Web Services\1.1\Microsoft.Exchange.WebServices.dll"
Add-Type -Path $ewsPath

$ews = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService -ArgumentList "Exchange2007_SP1"
$cred = (Get-Credential).GetNetworkCredential()
$ews.Credentials = New-Object System.Net.NetworkCredential -ArgumentList $cred.UserName, $cred.Password, $cred.Domain
$ews.AutodiscoverUrl( ( Read-Host "Enter mailbox (email address)" ) )
$results = $ews.FindItems(
	"Inbox",
	( New-Object Microsoft.Exchange.WebServices.Data.ItemView -ArgumentList 10 )
)
$results.Items | ForEach-Object { $_.Subject }
