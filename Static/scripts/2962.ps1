function Get-FreeRam {
#.Synopsis
#  Gets the FreePhysicalMemory from the specified computer(s)
#.Parameter ComputerName
#  The name(s) of the computer(s) to get the Free Ram (FreePhysicalMemory) for.
#.Example
#   Get-FreeRam SDI-JBennett, Localhost
#
# Computer              FreePhysicalMemory
# --------              ------------------
# SDI-JBENNETT                     4180364
# SDI-JBENNETT                     4179764
[CmdletBinding()]
param(
  [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
  [string[]]$ComputerName='localhost'
)
process {
  Get-WmiObject -ComputerName $ComputerName Win32_OperatingSystem |
  Select-Object -Property @{name="Computer";expression={$_.__SERVER}}, FreePhysicalMemory
}
}


