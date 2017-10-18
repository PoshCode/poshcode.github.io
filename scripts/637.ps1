# Enumerate OpsMgr 2007 Object Discoveries targeted to Windows Server
# Date: 13/10/2008
# Author: Stefan Stranger (help from Jeremy Pavleck and Marco Shaw)
get-discovery |? {$_.Target -match (get-monitoringclass | where {$_.Name -eq "Microsoft.Windows.Server.Computer"}).Id} | select Name, DisplayName
