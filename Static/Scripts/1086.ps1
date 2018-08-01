###########################################################################"
#
# NAME: Get-SQLDatabaseFreespace.ps1
#
# AUTHOR: Jan Egil Ring
# EMAIL: jan.egil.ring@powershell.no
#
# COMMENT: Requires SQL Server 2008 Management Studio Express. The script gets free space from the specified SQL Database
#              and sends the result to the specified e-mail address.
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the creator, owner above has no warranty, obligations,
# or liability for such use.
#
# VERSION HISTORY:
# 1.0 10.05.2009 - Initial release
#
###########################################################################"

#Add SQL Server 2008 PowerShell snapin
Add-Pssnapin SqlServerProviderSnapin100

#Get free space in specified database
cd SQLSERVER:\SQL\SQL-server-name\Instance-name\Databases
$DB =  Get-Item "Database01"
$SpaceAvailable = $DB.SpaceAvailable
$formattedresult = $SpaceAvailable
$result = "{0:#.00}" -f ($SpaceAvailable/1kb)

#Send result to specified e-mail address
$smtpServer = "smtp-server-name" 
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg.From = "sender@domain.local"
$msg.To.Add("recipient@domain.local")
$msg.Subject = "Free space in Database01"
$msg.Body = "There are $result MB free space in Database01"
$smtp.Send($msg)

