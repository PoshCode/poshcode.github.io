<#
.SYNOPSIS
    Send mail to BCC using PowerShell
.DESCRIPTION
    This script is a re-developed MSDN Sample using PowerShell. It creates
    an email message then sends it with a BCC.
.NOTES
    File Name  : Send-BCCMail.ps1
	Author     : Thomas Lee - tfl@psp.co.uk
	Requires   : PowerShell V2 CTP3
.LINK
    Original Sample Posted to
	http://pshscripts.blogspot.com/2009/01/send-bccmailps1.html
	MSDN Sample and details at:
	http://msdn.microsoft.com/en-us/library/system.net.mail.mailaddresscollection.aspx
.EXAMPLE
    PS C:\foo> .\Send-BCCMail.ps1
    Sending an e-mail message to The PowerShell Doctor and "Thomas Lee" <tfl@reskit.net>
#>

###
# Start Script
###

# Create from, to, bcc and the message strucures
$From    = New-Object system.net.Mail.MailAddress "tfl@cookham.net", "Thomas Lee"
$To      = new-object system.net.mail.mailaddress "doctordns@gmail.com", "The PowerShell Doctor"
$Bcc     = New-Object system.Net.Mail.mailaddress "tfl@reskit.net", "Thomas Lee"
$Message = New-Object system.Net.Mail.MailMessage $From, $To

# Populate message
$Message.Subject = "Using the SmtpClient class and PowerShell."
$Message.Body    = "Using this feature, you can send an e-mail message from an"
$Message.Body   += "application very easily. `nEven better, you do it with PowerShell!"

# Add BCC
$Message.Bcc.Add($bcc);

# Create SMTP Client
$Server = "localhost"
$Client = New-Object System.Net.Mail.SmtpClient $server
$Client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
"Sending an e-mail message to {0} and {1}" -f $to.DisplayName, $Message.Bcc.ToString()

# send the message
try {
    $client.Send($message);
}  
catch {
"Exception caught in CreateBccTestMessage(): {0}" -f $Error[0]
}
