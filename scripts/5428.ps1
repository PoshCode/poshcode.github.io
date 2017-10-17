#requires -version 2.0
function Get-ShutdownTime {
  <#
    .NOTES
        Author: greg zakharov
  #>
  
  [DateTime]::FromFileTime(
    [BitConverter]::ToInt64(
      (gp HKLM:\SYSTEM\CurrentControlSet\Control\Windows).ShutdownTime, 0
    )
  )
}
