#requires -version 2

function Send-SMSMessage {
	<#
.SYNOPSIS
Send a Text Message (SMS) using Microsoft Outlook
.DESCRIPTION
Sends a Text Message (SMS) using the supplied parameters.
.PARAMETER To
Telephone number to send the text message to.
.PARAMETER Message
The message to send.
.EXAMPLE
Send-SMSMessage -To 555-12345 -Message "This is a test message"
.NOTES
Requires Windows PowerShell v2 and Microsoft Office Outlook 2010.
Not tested in Outlook 2003 or 2007, but it should work with the Microsoft Outlook SMS Add-in installed (download from Microsoft).
AUTHOR:    Jan Egil Ring
BLOG:      http://blog.powershell.no
LASTEDIT:  21.07.2010 
#>

	[CmdletBinding()]
	param (
	[parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	$To, 
	[parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	$Message 
	)

	#Check if Outlook are running
	$OutlookState = Get-Process | Where-Object {$_.Name -eq "outlook"}

	#Check whether Outlook is installed
	if (-not (Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\OUTLOOK.EXE")) {
		Write-Warning "Outlook are not installed. The message was not sent."
		break
	}

	#Check wheter an Text Messaging (SMS) account are set up in Outlook
	$outlook = New-Object -ComObject outlook.application
	if (-not (($outlook.Session.Accounts | Where-Object {$_.AccountType -eq "5"} | Measure-Object).Count -gt 0)) {
		Write-Warning "Outlook are installed, but no accounts are configured for Text Messaging (SMS). The message was not sent."
		break
	}


	#Send message
	$NewMessage = $outlook.CreateItem("olMobileItemSMS") 
	$NewMessage.To = $To
	$NewMessage.Body = $Message
	$NewMessage.Send($true)

	#Close outlook.exe if it was not running before executing this function   
	if (-not $OutlookState) {
		$outlook.Quit()
	}


}
