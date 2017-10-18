<# Pointers: #>
$EnableUser = 512
$DisableUser = 2
$PasswordNotExpire = 65536
$PasswordCantChange = 64
$UsersToDisable = "C:\scripts\Users_To_Disable.txt"
$users = Get-Content -path $UsersToDisable
$computer = $env:COMPUTERNAME


<# Main Script #>
Foreach($user in $users){
 $user = [ADSI]"WinNT://$computer/$user"
 $user.userflags = $DisableUser+$PasswordNotExpire+$PasswordCantChange
 #$user.Userflags = $EnableUser+$PasswordNotExpire+$PasswordCantChange
 $user.setinfo()
}
