function Get-ProductKey([String]$Computer = '.') {
  begin {
    $val = [Byte[]]([wmiclass]('\\' + $Computer + '\root\default:StdRegProv')).GetBinaryValue(
      2147483650, 'SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'DigitalProductId'
    ).uValue[52..66]
    $map = "BCDFGHJKMPQRTVWXY2346789"
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
  end {$key}
}

Get-ProductKey
