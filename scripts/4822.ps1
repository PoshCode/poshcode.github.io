Set-Alias psgetsid Get-UserSID

function Get-UserSID([String]$Computer = '.', [String]$User) {
  <#
    .EXAMPLE
        PS C:\>psgetsid
    .EXAMPLE
        PS C:\>psgetsid -c GZ -u greg
        GZ\greg: S-1-5-...
  #>
  begin {
    function Get-UserStatus {
      $script:usr = [Security.Principal.WindowsIdentity]::GetCurrent()
      return (New-Object Security.Principal.WindowsPrincipal $usr).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
      )
    }
    
    function Get-WmiSID([String]$Computer = '.') {
      (New-Object Management.ManagementClass(
        [Management.ManagementPath]('\\' + $Computer + '\root\cimv2:Win32_UserAccount')
      )).PSBase.GetInstances()
    }
  }
  process {
    if (!(Get-UserStatus)) {
      $usr.Name + ': ' + $usr.User.Value #limited user
    }
    else {
      if ($Computer -eq '.' -or $Computer -eq $usr.Name.Split('\')[0]) {
        $cur = Get-WmiSID | ? {$_.Caption -eq $usr.Name} #current admin
      }
      else {
        try {$cur = Get-WmiSID $Computer | ? {$_.Name -eq $User}}
        catch {$_.Exception.Message}
      }
      $cur.Caption + ': ' + $cur.SID
    }
  }
  end {}
}
