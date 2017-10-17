# Email-ServiceStatus

# Version 1.04
# Johnny Reel
# 11/26/13

# Suggested use is to run as scheduled task on a server. Will email the status of service(s) to recipient(s).

Send-MailMessage -To "user@company.com" -From "sender@company.com" -SmtpServer <servername> -Subject "<service or server name> Service Status" -body ((gsv -cn <servrename> -Name <servicename>) | Out-string)

exit 4
