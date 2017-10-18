# Synopsis:
# Windows Script to collect usernames and OU locations
# for User Account with Password Set to Never Expire
# and email .txt list to email address

# Author: VulcanX
# Date: 2011/10/11
# Version: 1.0

# Requirements:
# -Quest PSSnapin Installed Locally
# -SMTP Access to Relay/Exchange

# Import AD module for additionals cmdlets
Import-Module ActiveDirectory

# Add Quest Snapin for Get-Q* cmdlets
Add-PSSnapin Quest.ActiveRoles.ADManagement

# Create variable for use later in script
$currentDate = get-date -format "yyyy-MM-dd"

# Find all users with Password Set to Never Expire and Export to a txt
Get-Qaduser -PasswordNeverExpires | Out-File "C:\Password_Exp\Exp_$currentdate.txt"

# Create variable for logfile location + name
$attach = "C:\Password_Exp\Exp_$currentdate.txt"

# Send Email with .txt attachment to infosec
Send-MailMessage -From 'email1@domain.com' -to 'email2@domain.com' -Subject `
"Password Expiration - $currentDate" -Body "User Accounts whose Passwords Never Expire `n `r Please refer to the txt attachment" `
-Attachments $attach -SmtpServer 'smtp01.domain.com'
