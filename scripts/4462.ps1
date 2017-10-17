
  #############################################################################################
#
# NAME: Show-LastDatabaseBackup.ps1
# AUTHOR: Rob Sewell http://sqldbawithabeard.com
# DATE:06/08/2013
#
# COMMENTS: Load function for Showing Last Backup of a database on a server
# ————————————————————————

Function Show-LastDatabaseBackup ($SQLServer, $database)
{

$server = new-object "Microsoft.SqlServer.Management.Smo.Server" $SQLServer
$db = $server.Databases[$database]

Write-Host "Last Full Backup"
$LastFull = $db.LastBackupDate
if($lastfull -eq '01 January 0001 00:00:00')
{$LastFull = 'NEVER'}
Write-Host $LastFull

Write-Host "Last Diff Backup"
$LastDiff = $db.LastDifferentialBackupDate  
if($lastdiff -eq '01 January 0001 00:00:00')
{$Lastdiff = 'NEVER'}
Write-Host $Lastdiff

Write-Host "Last Log Backup"                                                                                                                                                         
$lastLog = $db.LastLogBackupDate 
if($lastlog -eq '01 January 0001 00:00:00')
{$Lastlog= 'NEVER'}
Write-Host $lastlog

}

