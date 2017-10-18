
# Description                                                                                                          
# ===========                                                                                                          
# This script is to check the Sybase ASE Server errorlog for certain strings indicating errors and other issues        
# a DBA should know about, and mails the results to a list of recipients. When the server is running, the               
# script will figure out the errorlog filename itself, though you can also specify the file name explicitly.           
# This script can be run as a daily 'Scheduled Task' job, so that the DBA receives a list of all new suspect errorlog  
# messages by email every day. By default, an email will always be sent after each run of this script, even             
# when no error messages have been found.                                                                                                                                                                                                     #
#                                                                                                                      
# The script will look for the following strings in the Sybase error log:                                              
#                                                                                                                       
# String Pattern To Search: "error","warning","severity","fail","full", "couldn","not found","not valid","invalid",    
#                           "threshold","unmirror","mirror","deadlock", "allow","NO_LOG","logsegment","syslogs         
#                                                                                                                      
# Alternate String Pattern To Search: "error","warning"                                                                
#                                                                                                                      
#   Usage:      Job Should Be Scheduled Hourly                                                                         
#                                                                                                                      
#   powershell -command  G:\YourScriptDirectory\SybaseErrorLogCheck.ps1 >G:\SCRIPTDirectory\Scripts\SybErrLog.Err      
#                                                                                                                       
#     Note: Enter Command string above when creating a Scheduled Task                                                  
#                                                                                                                      

#   Author:         Victor Flores                                                                                      
#   Date Written:   05/01/2011                                                                                          
#   Date Revised:                                                                                                      
#   Program:        SybaseErrorLogCheck.ps1                                                                            
#   Email:          rattler69@gmail.com                                                                                 
#   Language:       Powershell V2                                                                                      
# Copyright Note and Disclaimer                                                                                        

# This software is provided "as is"; there is no warranty of any kind.  While this software is believed to work              
# accurately, it may not work  correctly and/or reliably in a production environment. In no event shall                
# Victor Flores be liable for any damages resulting from the use of this software.                                     
#                                                                                                                   
#                                                                                                                      
#  Change Log:                                                                                                         
#               Date             Programmer                  Change(s)                                                 
#                                                                                                                       
#                                                                                                                      
#                                                                                                                       
#                                                                                                                      
#                                                                                                                      
#


###################  This program is written in Windows Powershell Version 2                         
###################  Install Powershell V2 and configure powershell to allow you to run scripts      



###################       Log Files used in the execution of the SybaseErrorLogCheck.ps1 program     
###################                   Change to your script directory                                

del G:\YourScriptDirectory\ErrorsFound.log
del G:\YourScriptDirectory\errlogfile.txt



################### Email Function to Email Error Log  Results to The Sybase DBA's                   
################### Usage: Change Recieving Account in $mailmesssage.To.Add                          
###################        Change $SMTPClient. To reference your sending SMTP Server                 
###################        Change $SMTPClient.Credentials to reference your sending email acct       
###################        Change $SMTPClient.Credentials to reference your sending email password   
#
function EmailResults 
{
$mailmessage = New-Object system.net.mail.mailmessage 
$mailmessage.from       = ("YourDBASendingAccount@YourCompanyEmailServer,com") 
$mailmessage.To.add("DBA1@your.company.com,DBA2@your.company.com")
$mailmessage.Subject     = $Subject
$mailmessage.Body        = $EmailBody
$mailmessage.IsBodyHTML  = $true
$SMTPClient             = New-Object Net.Mail.SmtpClient("YourCompanySMTPServer.com", 25) 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("YourDBASendingAccount@YourCompanyEmailServer.com", "password")
$SMTPClient.Send($mailmessage)
}

###################         Sybase Error Log Filtering. Logs can be filetered by Days or Hours       

###################                         Alternate Log Filter in Days                             
#####$today = Get-Date
#####$daysback = New-Timespan -days 17
#####$cutoff = $today - $daysback



###################                         Alternate Log Filter in Hours                            
$hoursback = New-Timespan -hours 12
$cutoff = $today - $hoursback




###################           Parsing Thru Sybase Error Log For Errors                               
################### Sybase Error Log Location:  E:\sybase\ASE-15_0\install\cbstest.log               

 
$LogFileByDate = Get-Content E:\sybase\ASE-15_0\install\cbstest.log | Foreach-Object { $elements = $_.Split("`t");`
$rv = 1 | Select-Object date, message;$rv.date = if($elements[0] -notmatch "^\d\d:\d{5}:\d{5}:\d{4}/\d\d/\d\d\s\d\d:\d\d:\d\d\.\d\d"){$elements >> G:\YourScriptDirectory\errlogfile.txt;"UNKNOWN"}else{ [DateTime]($elements[0].SubString(15,10))}`
#$rv.Date = [DateTime]($elements[0].SubString(15,10));`
$rv.Message = $elements[1]; $elements } | Where-Object { $rv.Date -gt $cutoff } 


###################    Errors Encountered in Sybase Error Log Output file based on date filter       
###################                File Created in your script directory                              

$LogFileByDate| out-file G:\YourScriptDirectory\LogFileByDate.txt


$ErrorsFound= Select-String -Path G:\YourScriptDirectory\LogFileByDate.txt  -pattern "error","warning","severity",`
              "fail","full", "couldn","not found","not valid","invalid", "threshold","unmirror",`
              "mirror","deadlock", "allow","NO_LOG","logsegment","syslogs"  





###################                         Errors Found in Your Sybase Error Log                    
$ErrorsFound | out-file G:\YourScriptDirectory\ErrorsFound.log



###################         Errors Found in Your Sybase Error Log  Emailed to DBA                    
###################         Change Subject Line to Something of your liking                          

$EmailBody = (gc G:\YourScriptDirectory\ErrorsFound.log | out-string)
$Subject = 'Sybase Error Log Report for YourSybaseServerName - Sybase Errors Have Been Encountered on YourSybaseServerName'


if ($emailbody.Length -gt 0)
{
EmailResults $Subject $Body
}
   























  





