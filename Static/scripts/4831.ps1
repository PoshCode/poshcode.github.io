Function Get-O365 {
$cred = Get-Credential -Message "Your username is your email address for O365"
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/powershell/" -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $session
$myMB = Get-Mailbox

Write-Host -ForegroundColor "Green" "Hello $($myMB.Name), your email address is $($myMB.WindowsEmailAddress), and your account was created $($myMB.WhenCreated)"
}
