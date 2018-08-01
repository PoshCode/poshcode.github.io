function Get-Uptime([String]$Computer = '.') {
  <#
    .NOTES
        Author: greg zakharov
  #>
  try {
    '{0:D2}:{1:D2}:{2:D2} up {3} day(s)' -f ($u =
      [TimeSpan]::FromSeconds((($wmi = (New-Object Management.ManagementClass(
        [Management.ManagementPath](
          '\\' + $Computer + '\root\cimv2:Win32_PerfRawData_PerfOS_System'
        )
      )).PSBase.GetInstances() | select Frequency_Object, TimeStamp_Object, `
      SystemUpTime).TimeStamp_Object - $wmi.SystemUpTime) / $wmi.Frequency_Object)
    ).Hours, $u.Minutes, $u.Seconds, $u.Days
  }
  catch {
    $_.Exception.InnerException
  }
}

# -or-

function Get-Uptime([String]$Computer = '.') {
  <#
    .NOTES
        Author: greg zakharov
  #>
  try {
    $pc = New-Object Diagnostics.PerformanceCounter('System', 'System Up Time', $true)
    $pc.MachineName = $Computer
    [void]$pc.NextValue()
    '{0:D2}:{1:D2}:{2:D2} up {3} day(s)' -f (
      $u = [TimeSpan]::FromSeconds($pc.NextValue())
    ).Hours, $u.Minutes, $u.Seconds, $u.Days
  }
  catch {
    $_.Exception.InnerException
  }
}
