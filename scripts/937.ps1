#region vars
$script:maileditor = "C:\Programme\vim\vim72\vim.exe"
$script:encryption = "C:\Programme\GNU\GnuPG\gpg.exe"
$script:enckey = "s.patrick1982@gmail.com"
$script:tempmail = "C:\temp\psmail.txt"
$script:sigmail = "C:\temp\halten\sig.txt"
$script:mailbody = ""
#endregion vars

#region initMail
function initHeader {
	$script:mailTo = ($script:mailTo).Split(',') | % { $_.Trim() }

	if (Test-Path $script:sigmail) {
		(Get-Content $script:sigmail | Out-String) | Out-File $script:tempmail
	}

	& $script:maileditor $script:tempmail

}

function initMail {
	$smtpserver = "smtpserver"
	$myuser = "yoursmtp"
	$mypass = "password"
	$myAddress = "Patrick <s.patrick1982@gmail.com>"
	
	$script:mail = New-Object System.Net.Mail.MailMessage
	$script:srv = New-Object System.Net.Mail.SmtpClient
	$script:srv.Host = $smtpserver
	$script:srv.Credentials = New-Object System.Net.NetworkCredential($myuser, $mypass)
	
	$script:mail.from = $myAddress
	foreach ($rcpt in $script:mailTo) {
		if ($rcpt -ne "") {
			$script:mail.To.Add($rcpt)
		}
	}
	$script:mail.subject = $script:subject
}

function initMailol {
	$script:outlook = New-Object -ComObject Outlook.Application
	$script:srv = New-Object -ComObject Redemption.SafeMailItem
	$script:omail = $outlook.CreateItem("olMailItem")
	$script:srv.Item = $script:omail

	#region check
	#User Input
	foreach ($rcpt in $script:mailTo) {
		$script:srv.Recipients.Add($rcpt) | Out-Null
	}

	#check recipients
	$check = $script:srv.Recipients.ResolveAll()
	
	if ($check -eq $False) {
		for ($i=0; $i -gt $script:sitem.Recipients.Count;$i++) {
			$script:srv.Recipients.Remove($i)
			exit(-1)
		}
	}
	#endregion

	$script:srv.item.Subject = $script:subject

	if ($script:debug -eq $true) {
		Write-Host "Mail an - " $script:sitem.Recipients
		Write-Host "Betreff - " $script:subject
	}
}
#endregion initMail

#region sendmail
function sendmail {
	Param (
		[Parameter(Position=0,Mandatory=$True,HelpMessage="Sending Type (srv,ol)"]
		[string]$script:client=$false,
		[Parameter(Position=1,Mandatory=$True,Helpmessage="Mail To"]
		[string]$script:mailTo=$false,
		[Parameter(Position=2,Mandatory=$True,HelpMessage="Subject"]
		[string]$script:subject=$false,
		[Parameter(Position=3,Mandatory=$false,Helpmessage="Signed/Encrypted"]
		[string]$script:mtype=$false
	)

	initheader($script:mailTo, $script:subject)
	
#region encrypt
	switch ($script:mtype) {
		s {
			& $script:encryption -a -r $script:enckey --clearsign $script:tempmail
			break;
		}
		
		e {
			& $script:encryption -a -r $script:enckey --encrypt $script:tempmail 
			break;
		}
	}
#endregion encrypt

#body
	if ($script:mtype -ne "") {
		$script:mailbody = (Get-Content $script:tempmail".asc" | Out-String)
	} else {
		$script:mailbody = (Get-Content $script:tempmail | Out-String)
	}		
	
#cleaning
	if (test-path $script:tempmail) { Remove-Item $script:tempmail -Confirm:$false }
	if (test-path $script:tempmail".asc" ) { Remove-Item $script:tempmail".asc" -Confirm:$false }
	
	switch ($script:client) {
		srv {
			initMail
			$script:mail.Body = $script:mailbody
 			$script:srv.Send($script:mail)
			break;
		}
		
		ol {
			initMailol
			$script:srv.Body = $script:mailbody
			$script:srv.Send()
			break;
		}
	}

}

