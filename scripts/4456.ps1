  #############################################################################################
#
# NAME: Search-SQLErrorLog.ps1
# AUTHOR: Rob Sewell http://sqldbawithabeard.com
# DATE:22/07/2013
#
# COMMENTS: Load function for Searching SQL Error Log 
#
<# Usage: Search-SQLErrorLog backup fade2black

   Output to file
        Search-SQLErrorLog backup fade2black|Out-File c:\temp\error.txt

   Email
        $ErrorLog = Search-SQLErrorLog FADE2BLACK
        Send-MailMessage -SmtpServer Mail.Server -to DBA@MyWork.com -Subject SQL Error Log Search for $Search -Body $ErrorLog 

   Email as attachment
        $ErrorLog = Search-SQLErrorLog FADE2BLACK|Out-File c:\temp\log.txt
        $Body = @"
                  Dear DBA, 

                  Please find attached the Error Log for $Search. 

                  You're Welcome. 

                  The Beard
                "@
         Send-MailMessage -SmtpServer Mail.Server -to DBA@MyWork.com -Subject "SQL Error Log" `
         -Body $Body -Attachments $ErrorLog
#>
# ————————————————————————

Function Search-SQLErrorLog ([string] $SearchTerm , [string] $SQLServer)
 {

 $Search = '*' + $SearchTerm + '*'

 

$server = new-object "Microsoft.SqlServer.Management.Smo.Server" $SQLServer

 
$server.ReadErrorLog(6)| Where-Object {$_.Text -like $Search} | Select LogDate, ProcessInfo, Text| Format-Table -Wrap -AutoSize
$server.ReadErrorLog(5)| Where-Object {$_.Text -like $Search} | Select LogDate, ProcessInfo, Text| Format-Table -Wrap -AutoSize
$server.ReadErrorLog(4)| Where-Object {$_.Text -like $Search} | Select LogDate, ProcessInfo, Text| Format-Table -Wrap -AutoSize
$server.ReadErrorLog(3)| Where-Object {$_.Text -like $Search} | Select LogDate, ProcessInfo, Text| Format-Table -Wrap -AutoSize
$server.ReadErrorLog(2)| Where-Object {$_.Text -like $Search} | Select LogDate, ProcessInfo, Text| Format-Table -Wrap -AutoSize 
$server.ReadErrorLog(1)| Where-Object {$_.Text -like $Search} | Select LogDate, ProcessInfo, Text| Format-Table -Wrap -AutoSize 
$server.ReadErrorLog(0)| Where-Object {$_.Text -like $Search} | Select LogDate, ProcessInfo, Text| Format-Table -Wrap -AutoSize 


}






