#requires -version 2.0
function Get-SystemUptime([String]$Computer = '.') {
  <#
    .NOTES
        Author: greg zakharov
  #>
  
  try {
    New-TimeSpan ([Management.ManagementDateTimeConverter]::ToDateTime(
      ((New-Object Management.ManagementClass(
        [Management.ManagementPath]('\\' + $Computer + '\root\cimv2:Win32_OperatingSystem')
      )).PSBase.GetInstances() | select LastBootUpTime).LastBootUpTime
    )) (date) | ft -a
  }
  catch [Management.Automation.MethodInvocationException] {
    Write-Host Access denied. -fo Red
  }
}
