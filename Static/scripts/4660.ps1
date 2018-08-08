function Get-ParentProcess {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [String]$ProcessName
  )
  
  begin {
    function get([String]$proc) {
      return (New-Object Diagnostics.PerformanceCounter("Process", "Creating Process ID", $proc)).RawValue
    }
  }
  process {
    [Diagnostics.Process]::GetProcessesByName($ProcessName) | % {
      $p = ps -ea 0 -Id (get $ProcessName)
      if ($p -ne $null) {
        Write-Host $p.ProcessName $p.Id -fo Magenta
        '{0}--{1} {2}' -f (' ' + [Char]28), $ProcessName, $_.Id
      }
      else {
        Write-Warning $('process ' + $ProcessName  + ' has not parent process.')
      }
    }
    ''
  }
}
