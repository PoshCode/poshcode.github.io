function Get-ProductKey {
  param(
    [Parameter(Mandatory=$false,
               ValueFromPipeline=$true)]
    [String]$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
  )
  
  begin {
    $map = "BCDFGHJKMPQRTVWXY2346789"
    $val = (gp $RegistryPath).DigitalProductId[52..66]
    $key = ""
  }
  process {
    for ($i = 24; $i -ge 0; $i--) {
      $k = 0
      for ($j = 14; $j -ge 0; $j--) {
        $k = ($k * 256) -bxor $val[$j]
        $val[$j] = [Math]::Floor([Double]($k / 24))
        $k = $k % 24
      }
      $key = $map[$k] + $key
      if (($i % 5) -eq 0 -and $i -ne 0) {$key = "-" + $key}
    }
  }
  end{$key}
}
