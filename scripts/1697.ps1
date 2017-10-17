$file = "MYFILE.TXT"

$smtpServer = "MYSMTPSERVER.EMAIL.CO.UK"

$msg = new-object Net.Mail.MailMessage
$att = new-object Net.Mail.Attachment($file)
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = "FROMME@EMAIL.CO.UK"
$msg.To.Add("TOME@EMAIL.CO.UK")
$msg.Subject = "MY SUBJECT"
$msg.Body = "MY TEXT FOR THE EMAIL"
$msg.Attachments.Add($att)

$smtp.Send($msg)

$att.Dispose()
