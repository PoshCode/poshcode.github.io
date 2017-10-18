function Get-UserStatus {
  <#
    .Synopsis
        Get extended information about local user.
    .Description
        There is no input arguments, just specify Get-UserStatus or his alias whoami.
    .Link
        http://msdn.microsoft.com/en-us/library/system.security.principal.aspx
        http://poshcode.org/3979
  #>
  $usr = [Security.Principal.WindowsIdentity]::GetCurrent()
  $res = (New-Object Security.Principal.WindowsPrincipal $usr).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
  )

  "{0, 9}: {1}" -f "User", $usr.Name
  "{0, 9}: {1}" -f "SID", $usr.Owner.Value
  "{0, 9}: {1}" -f "IsAdmin", $res
  "{0, 9}:" -f "Groups"
  $usr.Groups | % {"`t   " + $_.Translate([Security.Principal.NTAccount]).Value} | sort
  ""
}

Set-Alias whoami Get-UserStatus
