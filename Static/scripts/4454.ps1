
 #############################################################################################
#
# NAME: Show-DatabasesOnServer.ps1
# AUTHOR: Rob Sewell http://sqldbawithabeard.com
# DATE:22/07/2013
#
# COMMENTS: Load function for finding a databases on Server
# ————————————————————————


Function Show-DatabasesOnServer ([string]$Server)
{
$srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server

Write-Host " The Databases on $Server Are As Follows"
$srv.databases| Select Name
}
