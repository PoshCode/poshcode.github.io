$LastEvent = Get-EventLog AppAssure -newest 1
$TimeCheck = Get-EventLog AppAssure -After (Get-Date).AddMinutes(-75)
If ($TimeCheck -eq $null)
{
$EmailFrom = "jeff@example.com"
$EmailTo = "jeff@example.com"
$Subject = "AppAssure has hung - last event was at " + $LastEvent.TimeGenerated
$Body = "AppAssure has hung - last event was at " + $LastEvent.TimeGenerated
$SMTPServer = "mail.example.com"
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25)
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
Write-EventLog -LogName ScriptEvents -Source AppAssureHung -EventId 99 -Message $Body
Restart-Computer -Force
}

