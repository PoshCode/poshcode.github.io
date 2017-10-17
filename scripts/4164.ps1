#############################################################################################
#
# NAME: SQLErrorLog.ps1
# AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com @fade2blackuk
# DATE:15/05/2013
#
# COMMENTS: This script will display the SQL Error Log for a remote server
# ------------------------------------------------------------------------
$Server = Read-Host "Please Enter the Server" 
$srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server  
$Results = $srv.ReadErrorLog(0) | format-table -Wrap -AutoSize  
$Results
