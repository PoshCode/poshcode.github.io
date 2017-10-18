##################################
#This errors out in ISE, so use cmd window.
#The script below fixes the error just below.
#Cannot access the local farm. Verify that the local farm is 
#properly configured, currently available, and that you have 
#the appropriate permissions to access the database before 
#trying again.

#Enable-PSRemoting -Force 
#Enable-WSManCredSSP -Role Server -Force

##################################


Add-PSSnapin Microsoft.SharePoint.Powershell -ErrorAction SilentlyContinue  
 
 try
 {

   
# specify here your backup folder 
$backupRoot = "\\SERVER\SPFarmBackUP\" 
$logPath = Join-Path $backupRoot "_logs" 
$tmpPath = Join-Path $backupRoot "_tmp" 
# removes all the old backup files on the target folder (valid values: 0 = do not remove; 1 = remove files 
$clearUpOldFiles = 0  
# specifies the days for the backups that should be persisted 
$removeFilesOlderThanDays = -1 
# specifies the backupfolder based on the current weekday (Monday... etc.) 
$todaysBackupFolder = Join-Path $backupRoot ((Get-Date).DayOfWeek.toString())  
 
# generate all necessary folders if they are missing 
if (-not (Test-Path $logPath)) {   
  New-Item $logPath -type directory 
}  
 
if (-not (Test-Path $tmpPath)) {   
  New-Item $tmpPath -type directory 
}  
 
if (-not (Test-Path $todaysBackupFolder)) {   
  New-Item $todaysBackupFolder -type directory 
}  
 
# creates a log file  
Start-Transcript -Path (Join-Path $logPath ((Get-Date).ToString('MMddyyyy_hhmmss') + ".log"))

$TXTFile = Join-Path $logPath ((Get-Date).ToString('MMddyyyy_hhmmss') + ".log")

# loop over all web applications (specify filter criteria here if you want to filter them out) 
foreach ($webApplication in Get-SPWebApplication) {     
  Write-Host     
  Write-Host     
  Write-Host "Processing $webApplication"    
  Write-Host "*******************************"          
 
  foreach ($site in $webApplication.Sites) {                 
    # we have to replace some characters from the url name         
    $name = $site.Url.Replace("http://", "").Replace("https://", "").Replace("/", "_").Replace(".", "_");         
    # replace all special characters from url with underscores         
    [System.Text.RegularExpressions.Regex]::Replace($name,"[^1-9a-zA-Z_]","_");                  
    # define the backup name         
    $backupPath = Join-Path $tmpPath ($name + (Get-Date).ToString('MMddyyyy_hhmmss') + ".bak")                  
 
    Write-Host "Backing up $site to $backupPath"         
    Write-Host                  
     
    # backup the site         
    Backup-SPSite -Identity $site.Url -Path $backupPath     
  }          
 
  Write-Host "*******************************"     
  Write-Host "*******************************" 
}  
 
Write-Host 
Write-Host  
 
# remove the old backup files in the todays folder if specified 
if ($clearUpOldFiles -eq 1) {   
  Write-Host "Cleaning up the folder $todaysBackupFolder"   
  Remove-Item ($todaysBackupFolder + "\*")  
}  
 
# move all backup files from the tmp folder to the target folder 
Write-Host "Moving backups from $tmpPath to $todaysBackupFolder" 
Move-Item -Path ($tmpPath + "\*") -Destination $todaysBackupFolder 
# you can specify an additial parameter that removes filders older than the days you specified 
if ($removeFilesOlderThanDays -gt 0) {   
  Write-Host "Checking removal policy on $todaysBackupFolder"   
  $toRemove = (Get-Date).AddDays(-$removeFilesOlderThanDays)   
  $filesToRemove = Get-ChildItem $todaysBackupFolder | Where {$_.LastWriteTime -le “$toRemove”}      
 
  foreach ($fileToRemove in $filesToRemove)  {     
    Write-Host "Removing the file $fileToRemove because it is older than $removeFilesOlderThanDays days"      
    Remove-Item (Join-Path $todaysBackupFolder $fileToRemove) | out-null   
  } 
} 
  
Stop-Transcript

    
  $today = (Get-Date -Format MM-dd-yyyy)
 # Edit the From Address as per your environment.
  $emailFrom = "admin@domain.com"
 # Edit the mail address to which the Notification should be sent.
  $emailTo = "admin@domain.com"
 # Subject for the notification email. The + “$today” part will add the date in the subject.
  $subject = "Site collections on Farm Backup Report for this day "+"$today"
 # Body or the notification email. The + “$today” part will add the date in the subject.
  $body = "The SharePoint backup of all Site collections in the farm has been run and was successful this day "+"$today"
  # IP address of your SMTP server. Make sure relay Is enabled for the SharePoint server on your SMTP server
  $smtpServer = "smtp.domain.com"
  $smtp = new-object Net.Mail.SmtpClient($smtpServer)
  Send-MailMessage -SmtpServer $smtpServer -From $emailFrom -To $emailTo -Subject $subject -Body $body -Attachment $TXTFile
  

}

catch
{
  [System.Exception] 
  $ErrorMessage = $_.Exception.Message
  # Configure the below parameters as per the above.
  $emailFrom = "admin@domain.com"
  $emailTo = "admin@domain.com"
  $subject = "Site collections on Farm Backup Report for this day "+"$today"
  $body = "The SharePoint backup of all Site collections in the farm has been run and the Job failed today, the "+"$today because... $ErrorMessage."
  $smtpServer = "smtp.domain.com"
  $smtp = new-object Net.Mail.SmtpClient($smtpServer)
  Send-MailMessage -SmtpServer $smtpServer -From $emailFrom -To $emailTo -Subject $subject -Body $body
}
