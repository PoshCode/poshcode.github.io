Function GetMsgBody {
	Write-Output @"
		<p>Dear $name,</p>
		Your ABC network account is about to expire.<br/>
		Please email helpdesk@abc.com or simply hit 'reply', and include the following details to have your account extended.<br/>
		<br/>
		Your name:<br/>
		The department you currently volunteer in:<br/>
		The staff supervisor's name you currently report to:<br/>
		The current status of your involvement with ABC (Staff/Student/Volunteer):<br/>
		<br/>
		Kind Regards,<br/>
		ABC IT Services
"@
}

Get-QADUser -AccountExpiresBefore "31/01/2012" -Enabled -SizeLimit 0 | ForEach-Object {
	$email = $_.mail
	$name = $_.givenName
	[string]$body = GetMsgBody
	Send-MailMessage -BodyAsHtml:$true -Body $body -To $email -From 'helpdesk@abc.com' -SmtpServer 'smtp.abc.com' -Subject "Your account is about to expire"
	}
