#requires -version 2.0
Set-Alias whoami Get-UserStatus

function Get-UserStatus {
  <#
    .NOTES
        Author: greg zakharov
  #>
  $usr = [Security.Principal.WindowsIdentity]::GetCurrent()
  New-Object PSObject -Property @{
    User    = $usr.Name
    SID     = $usr.Owner.Value
    IsAdmin = $(
      (New-Object Security.Principal.WindowsPrincipal $usr).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
      )
    )
    Groups  = $($usr.Groups | % {
      $_.Translate([Security.Principal.NTAccount]).Value} | sort
    )
  }
}
