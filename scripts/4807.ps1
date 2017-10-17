function get-whoisabuse ([string][ValidatePattern("^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")]$ipaddress)
{

[xml]$a = (Invoke-WebRequest -Uri "http://whois.arin.net/rest/ip/$ipaddress" -ContentType "text/xml").content

[xml]$pocs = (Invoke-WebRequest -Uri (($a.net.orgRef).'#text' + "/pocs") -ContentType "text/xml").content

[xml]$abuse = (Invoke-WebRequest -Uri (($pocs.pocs.pocLinkRef | where {$_.function -eq "AB"}).'#text') -ContentType "text/xml").content

[array]$result = $abuse.poc.emails.email

$result

}
