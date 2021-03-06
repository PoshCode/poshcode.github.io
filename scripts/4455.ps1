
 #############################################################################################
#
# NAME: Show-LatestSQLErrorLog.ps1
# AUTHOR: Rob Sewell http://sqldbawithabeard.com
# DATE:22/07/2013
#
# COMMENTS: Load function for reading last days current SQL Error Log for Server
# ————————————————————————


Function Show-LatestSQLErrorLog ([string]$Server)
{

                                
                                $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server 
                                $logDate = (get-date).AddDays(-1)
                                $Results = $srv.ReadErrorLog(0) |Where-Object {$_.LogDate -gt $logDate}| format-table -Wrap -AutoSize 
                                $Results         

}

