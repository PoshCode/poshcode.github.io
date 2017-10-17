cls
<# 
Writer: Ritesh P.

#>
# Core Declaration
$date = ((get-date).toString('MM-dd-yyyy'))   
$time = ((Get-Date).toString('HH-mm-ss'))
#$what = "/COPYALL /S /B" 
#$options = "/R:0 /W:0 /FP"
$NewDestinationPath = '\\'+'infra'+'\c$\data1\'+$date+'-'+$time   # 

When I add $time to create Destination folder, Which protect 

from folder duplication and also saved 8line of for loop code  ;)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

+++++++
$servers = 'infra'
foreach($Server in $Servers) 
{
	$sourceFolder = '\\'+$server+'\c$\data\'
	
			if (Test-Path $sourceFolder){
				$desti= 

$NewDestinationPath+'\'+$Server
				robocopy.exe 

$sourceFolder $desti '*pub*.txt' /COPYALL /S /B /R:0 /W:0 /FP 

/LOG:$date-$time-$server-'robocopy_log'.txt
				#Write-output "Files 

found:" on $sourceFolder __ | Out-File 

$NewDestinationPath'\'log_$date.txt -Append 
		}
			else{
    			#"Files does not exist on $server " | 

Out-File $NewDestinationPath'\'Failed_BOS_$date.txt -Append 
		}
	
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

++++++
# Email Declaration
#$file = c:\scripts\PublicFolderData\log.txt
$smtpServer = “infra.al.com”
$msg = new-object Net.Mail.MailMessage
#$att = new-object Net.Mail.Attachment($file)
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg.From = “BOS_Space_Report@al.com”
$msg.To.Add('riteshp@al.com')
$msg.Subject = “BOS Private Space Utilization Report”
#$msg.IsBodyHtml = $true
$msg.Body = "BOS Private Folder Utilization Space Report 

Generated `n " + $desti 
$msg.Body += "Log files located at 

\\infra\c$\script\publicfolderdata\servername+date+robo_logfile.tx

t" 
#$msg.Body = Get-Content "c:\data\body.txt"
#$msg.Attachments.Add($att)
$smtp.Send($msg)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

++++++

<#

 "My pain may be the reason for 
               somebody's laugh
 But my laugh must never be the 
    reason for somebody's pain"
			   
			   -Charlie Chaplin 

#>
