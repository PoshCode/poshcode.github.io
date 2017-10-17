  #############################################################################################
#
# NAME: Show-SQLProcesses.ps1
# AUTHOR: Rob Sewell http://sqldbawithabeard.com
# DATE:06/08/2013
#
# COMMENTS: Load function for Showing Processes on a SQL Server
# ————————————————————————

Function Show-SQLProcesses ($SQLServer)

{
$server = new-object "Microsoft.SqlServer.Management.Smo.Server" $SQLServer
$Server.EnumProcesses()|Select Spid,BlockingSpid, Login, Host,Status,Program,Command,Database,Cpu,MemUsage |Format-Table -wrap -auto

$OUTPUT= [System.Windows.Forms.MessageBox]::Show("Do you want to Kill a process?" , "Question" , 4) 

if ($OUTPUT -eq "YES" ) 
{

$spid = Read-Host "Which SPID?"
$Server.KillProcess($Spid)


} 
else 
{ 

}

}
