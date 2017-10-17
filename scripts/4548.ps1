function Get-ParentProcess {
  <#
    .LINK
        Follow me on twitter @gregzakharov
        http://msdn.microsoft.com/en-US/library/system.diagnostics.performancecounter.aspx
        Get-Process
  #>
  param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$ProcessName
  )
  
  begin {
    ps | % {$hash = @{}}{
      $pc = New-Object Diagnostics.PerformanceCounter("Process", "Creating Process ID", $_.ProcessName)
      try {
        $ps = [Diagnostics.Process]::GetProcessById($pc.RawValue)
        $hash[$pc.InstanceName] = $pc.RawValue
      }
      catch {
        $hash[$pc.InstanceName] = -1
      }
    }
  }
  process {
    [Diagnostics.Process]::GetProcessesByName($ProcessName) | % {
      if ($hash[$_.ProcessName] -ne -1) {
        foreach ($p in @(ps -id $hash[$ProcessName])){
          '"{0}" (PID {1}) is parent for "{2}" (PID {3})"' -f $p.ProcessName, $p.Id, $_.ProcessName, $_.Id
        }
      }
      else { Write-Host `"$ProcessName`" has not parent process. -fo cyan}
    }
  }
}
