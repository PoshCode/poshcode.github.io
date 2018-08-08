function Get-DCsFromDNS($DomainName){    
$DCs = get-dns _ldap._tcp.dc._msdcs.$DomainName -Type srv | select -ExpandProperty RecordsRR | 
 %{$_.record.target} | select -Unique | sort | %{
get-dns $_ | select -ExpandProperty Answers | select Name,@{n='IPAddress';e={$_.Record}}}
return $DCs
}

