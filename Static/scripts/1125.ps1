#Returns the priority SRV hostname and port for a particular service and domain.
function Get-SRVPriority {
param( [string] $query = $( Throw "Query required in the format _Service._Proto.DomainName (ie, `"_ftp._tcp.myserver.net`" or `"_xmpp-client._tcp.gmail.com`").") )
	
  #get all the SRV records for this service/domain, sorted by descending priority (lower priority = preferred server)
  $srvrecords = @(get-dns $query -type SRV | sort-object -Property PRIORITY -des)
  #verify that there are some records
  if ($srvrecords.Length -eq 0) { Throw "No records found." }
  #now gather all the records that are of the lowest priority, and sort them by weight (higher weight = preferred server)
  $srvrecords = @($srvrecords | ?{$_.PRIORITY -eq $srvrecords[0].PRIORITY} | sort -Property WEIGHT)
  #got it:
  "$($srvrecords[0].TARGET):$($srvrecords[0].PORT)"
}
