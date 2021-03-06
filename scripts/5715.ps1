#region Variables - Set up Data source, SMTP info, and To address(s)
# The input CSV needs one column with the header "Octet" - This should contain the IP addresses one on each line to look  up.
$IPADDRESSES = Import-Csv '<Path to CSV>'
$Smtpserver = '<Mail server Info>'
$To = '<To Email Address>'
#endregion

#region Check the Honeypot Project website - read the return info and look for positive criteria or Negitive Criteria
foreach ($IPADD in $IPADDRESSES)
{
[string]$IP1 = $IPADD.Octet
[string]$Outfilehtml = 'c:\'+$IP1+'.html'
[string]$URL = "http://www.projecthoneypot.org/ip_"+$IP1
[string]$positive = "The Project Honey Pot system has detected behavior from the IP address"
[string]$negitive = "We don't have data on this IP currently. If you know something, you may"
$web = Invoke-WebRequest -Uri $URL
$string = $web.Content
#$IP1
if ($string -match $positive) {
    Send-MailMessage -SmtpServer $Smtpserver -To $To -From 'Honeypot_YES@yourdomain.com' -BodyAsHtml $string -Subject $IP1
} 
# Just in case you want an Email no matter what - yes or no
if ($string -match $negitive) {
	Send-MailMessage -SmtpServer $Smtpserver -To $To -From 'Honeypot_NO@yourdomain.com' -Subject $IP1 
}
}
#endregion 

