#Active Directory Group Name To Be Edited
#Load Active Directory Module
if(@(get-module | where-object {$_.Name -eq "ActiveDirectory"} ).count -eq 0) {import-module ActiveDirectory}

# get domain maximumPasswordAge value

$MaxPassAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.days

if($MaxPassAge -le 0)

{ 

  throw "Domain 'MaximumPasswordAge' password policy is not configured."

} 

#Send Alert to User

$DaysToExpire = 7

$LogPath = "C:\Scripts\Logs\PasswordExpire"

#Create Daily Log File
$a=get-date -format "ddMMyyyy"
echo "Daily Log for $a" | Out-File $LogPath\$a.txt -append
echo "-----------------------" | Out-File $LogPath\$a.txt -append

#Check users that have a password expiring in 7 days or less

Get-ADUser -SearchBase (Get-ADRootDSE).defaultNamingContext -Filter {(Enabled -eq "True") -and (PasswordNeverExpires -eq "False") -and (mail -like "*")} -Properties * | Select-Object Name,SamAccountName,mail,@{Name="Expires";Expression={ $MaxPassAge - ((Get-Date) - ($_.PasswordLastSet)).days}} | Where-Object {$_.Expires -gt 0 -AND $_.Expires -le $DaysToExpire } | ForEach-Object {

#Send Email to user that password is going to expire

$SMTPserver = "exchange.yourdomain.com"

$from = "noreply@yourdomain.com"

$to = $_.mail

$subject = "Password reminder: Your Windows password will expire in $($_.Expires) days"

$emailbody = "Your Windows password for the account $($_.SamAccountName) will expire in $($_.Expires) days.  For those of you on a Windows machine, please press CTRL-ALT-DEL and click Change Password.  

For all others, you can change it with a web browser by using this link: https://yourdomain.com/owa/?ae=Options&t=ChangePassword

Please remember to also update your password everywhere that might use your credentials like your phone or instant messaging application. 

If you need help changing your password please contact helpdesk@yourdomain.com"


$mailer = new-object Net.Mail.SMTPclient($SMTPserver)

$msg = new-object Net.Mail.MailMessage($from, $to, $subject, $emailbody)

$mailer.send($msg) 

echo $($_.mail)  | Out-File $LogPath\$a.txt -append

}
