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
  Get-WmiObject -ComputerName $ComputerName Win32_WinSAT | ForEach-Object {
     if($_.WinSatAssessmentState -ne 1) {
        Write-Warning "WinSAT data for '$($_.__SERVER)' is out of date ($($_.WinSatAssessmentState))"
     }
     $_
  } | Select-Object -Property @{name="Computer";expression={$_.__SERVER}}, *Score #, WinSPRLevel
}
}
