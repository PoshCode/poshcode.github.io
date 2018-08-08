function Get-WindowsExperienceRating {
#.Synopsis
#  Gets the Windows Experience Ratings
#.Parameter ComputerName
#  The name(s) of the computer(s) to get the Windows Experience (WinSat) numbers for.
[CmdletBinding()]
param(
  [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
  [string[]]$ComputerName='localhost'
)
process {
  $winSat = Get-WmiObject -ComputerName $ComputerName Win32_WinSAT
  if($WinSat.WinSatAssessmentState -ne 1) {
     Write-Warning "WinSAT data for '$($winSat.__SERVER)' is out of date ($($winSat.WinSatAssessmentState))"
  }
  Select-Object -Input $winSat -Property @{name="Computer";expression={$_.__SERVER}}, *Score #, WinSPRLevel
}
}
