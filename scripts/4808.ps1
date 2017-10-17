function get-whoisabuse ([string][validatescript({ $ip = $null; [net.ipaddress]::tryparse($_, [ref]$ip); })]$ipaddress)
{

[xml]$a = (Invoke-WebRequest -Uri "http://whois.arin.net/rest/ip/$ipaddress" -ContentType "text/xml").content

[xml]$pocs = (Invoke-WebRequest -Uri (($a.net.orgRef).'#text' + "/pocs") -ContentType "text/xml").content

[xml]$abuse = (Invoke-WebRequest -Uri (($pocs.pocs.pocLinkRef | where {$_.function -eq "AB"}).'#text') -ContentType "text/xml").content

[array]$result = $abuse.poc.emails.email

$result

}
