#requires -version 2.0
function Get-SystemInstallDate {
  <#
    .NOTES
        Author: greg zakharov
  #>
  
  try {
    ([wmi]'').ConvertToDateTime((gwmi Win32_OperatingSystem).InstallDate)
  }
  catch [Management.Automation.RuntimeException] {
    if ($_.Exception) {
      [TimeZone]::CurrentTimeZone.ToLocalTime([DateTime]'1.1.1970').AddSeconds(
        (gp 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').InstallDate
      )
    }
  }
}
