#checking with COM - be sure that you have CompatUI.Util
"Is {0} admin? {1}`n" -f $env:username, [bool](New-Object -com CompatUI.Util).CheckAdminPrivileges()

#traditional way
$usr = [Security.Principal.WindowsIdentity]::GetCurrent()
$res = (New-Object Security.Principal.WindowsPrincipal $usr).IsInRole(
  [Security.Principal.WindowsBuiltInRole]::Administrator
)
"Is {0} admin? {1}`n" -f $usr.Name.Split("\")[1], $res

#dirty way with cultures
[xml]$loc = @'
<Culture>
  <Language en="Administrators"
            de="Administratoren"
            ru="&#1040;&#1076;&#1084;&#1080;&#1085;&#1080;&#1089;&#1090;&#1088;&#1072;&#1090;&#1086;&#1088;&#1099;" />
</Culture>
'@

$d = $env:userdomain + '/' + $loc.Culture.Language.((Get-Culture).TwoLetterISOLanguageName)
$res = [bool]@(([adsi]"WinNT://$d").PSBase.Invoke("Members")).Length
"Is {0} admin? {1}`n" -f $env:username, $res
