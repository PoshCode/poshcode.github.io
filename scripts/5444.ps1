function Find-PotentialAdmin {
  <#
    .NOTES
        Author: greg zakharov
  #>
  
  if ((New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
  )).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
  )) {
    Write-Warning 'you are administrator!'
    return
  }
  
  if (($all = @(gci ($dir = Split-Path $env:userprofile) | ? {
    $_.Name -notmatch $('(?:(All\sUsers)|(' + $env:username + '))')
  })).Length -eq 1) {
    $all[0].Name
  }
  else {
    $ErrorActionPreference = 0
    $all | % {
      $Error.Clear()
      [void](Get-Acl (Join-Path $dir $_))
      if ($Error.Count -eq 1) {$_.Name}
    }
  }
}
