function get-whoisabuse ([string]$ipaddress)
{

[xml]$a = (Invoke-WebRequest -Uri "http://whois.arin.net/rest/ip/$ip" -ContentType "text/xml").content

[xml]$pocs = (Invoke-WebRequest -Uri ("http://whois.arin.net/rest/net/" + $a.net.handle + "/pocs") -ContentType "text/xml").content

[xml]$abuse = (Invoke-WebRequest -Uri (($pocs.pocs.pocLinkRef | where {$_.function -eq "AB"}).'#text') -ContentType "text/xml").content

[array]$result = $abuse.poc.emails.email

$result

}
