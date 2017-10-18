# Enumerate OpsMgr 2007 Object Discoveries targeted to Windows Server
# Date: 20/10/2008
# Author: Stefan Stranger (help from Jeremy Pavleck and Marco Shaw)
# Author: Cory Delamarter (increased speed)
get-discovery | ? {$_.Target -match $(get-monitoringclass -Name "Microsoft.Windows.Server.Computer").Id} | ft Name, DisplayName
