#Powershell Script Made by Paulo Seabra. Use it freely, but please give proper credits.

# Set Session variables
$Computer=hostname
$Events=Get-EventLog -LogName Application -EntryType Warning,Error -Source Microsoft-Windows-Backup -After (Get-Date).AddHours(-24)

# Set email parameters
$PSEmailServer = "fqdn of email server"
$EmailFrom="youremail@yourdomain.xx"
$EmailTo="youremail@yourdomain.xx"
$EmailSubject="Backup - $Computer"


# Build body Error/Warning Messages
$EmailBody="<html><head><meta http-equiv=`"Content-Type`" content=`"text/html; charset=utf-8`"></head>"+ $Computer + "<br><br>"
If (!$Events) {exit}
foreach ($Event in $Events){
if ($Events)
{    $Emailbody = $Emailbody + $Event.message + "<br>" +"<br>"}
}

Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $EmailSubject -Body $EmailBody -BodyAsHtml -Encoding ([System.Text.Encoding]::UTF8)
