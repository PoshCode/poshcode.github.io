Param($VC,$ESXCreds=(Get-Credential))

Write-Host "Connecting to VC to get ESX Hosts"
Connect-VIServer $VC | out-null

$ESXHosts = Get-VMHost

foreach($esxhost in $ESXHosts)
{
   Write-Host " Connecting to $esxhost"
   Connect-VIServer $esxhost.name -cred $ESXCreds | out-null
   $SNMPHost = Get-VMHostSnmp
   $SNMPHost | Add-Member -MemberType NoteProperty -Name ESXHost -Value $esxhost.name
   $SNMPHost
}
