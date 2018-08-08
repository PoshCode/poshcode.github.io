#requires -version 2.0
Set-Alias uptime Get-SystemUptime

function Get-SystemUptime {
  <#
    .SYNOPSIS
        Returns uptime of system.
    .DESCRIPTION
        Actually, this demo shows that you don't need an access to Win32_OperatingSystem
        to get system last boot uptime.
  #>
  [CmdletBinding()]
  param()
  
  begin {
    $usr = [Security.Principal.WindowsIdentity]::GetCurrent()
    $res = (New-Object Security.Principal.WindowsPrincipal $usr).IsInRole(
      [Security.Principal.WindowsBuiltInRole]::Administrator
    )
  }
  process {
    switch ($res) {
      $true{
        $wmi = gwmi Win32_OperatingSystem
        New-TimeSpan $wmi.ConvertToDateTime($wmi.LastBootUpTime) (Get-Date)
      }
      $false{[TimeSpan]::FromMilliseconds([Environment]::TickCount)}
    }
  }
  end{}
}

uptime
