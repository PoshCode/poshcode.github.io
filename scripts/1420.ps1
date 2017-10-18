function dnsref ($computername) {
$ErrorActionPreference = "SilentlyContinue"
$testrun=$Null
trap { 
	Write-Host "ERROR: $computername does not exist in DNS" -fore Yellow
	Throw $_ }
$testrun=[net.dns]::GetHostByName($computername) 
if ($testrun -eq $Null){
	Write-Host "No DNS Record" }
else { 
	foreach ($alias in $testrun){
 			PingX($alias.addresslist)
 		}
	}
}
function PingX($ip) {
	$ErrorActionPreference="SilentlyContinue"
	$ping = New-Object System.Net.NetworkInformation.ping
	#trap {$_.Exception.Message ;$pingres = $_Exception.Message; continue}
	if ($_Exception.Message -eq $null) {
	$pingres = ($ping.send($ip)).Status | Out-Null
	Write-Host $computername - $ip is REACHABLE -background "GREEN" -foreground "BLACk"}
	else
	{Write-Host $computername - $ip is NOT reachable  -background "RED" -foreground "BLACk"}
	return $pingres
}
