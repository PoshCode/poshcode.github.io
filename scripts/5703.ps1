# Release COM Object
function Remove-ComObject {
 # Requires -Version 2.0
 [CmdletBinding()]
 param()
 end {
  Start-Sleep -Milliseconds 500
  [Management.Automation.ScopedItemOptions]$scopedOpt = 'ReadOnly, Constant'
  Get-Variable -Scope 1 | Where-Object {
   $_.Value.pstypenames -contains 'System.__ComObject' -and -not ($scopedOpt -band $_.Options)
  } | Remove-Variable -Scope 1 -Verbose:([Bool]$PSBoundParameters['Verbose'].IsPresent)
  [gc]::Collect()
 }
}
