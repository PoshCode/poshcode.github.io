#function Get-ProcessorGraph {
  begin {
    $pc = New-Object Diagnostics.PerformanceCounter("Processor", "% Processor Time", "_Total")
    $raw = $host.UI.RawUI
    
    function strip([Int32]$x, [Int32]$y, [Int32]$z, [ConsoleColor]$bc) {
      $pos = $raw.WindowPosition;$pos.X += $x;$pos.Y += $y
      $row = $raw.NewBufferCellArray(@(' ' * $z), $bc, $bc)
      $raw.SetBufferContents($pos, $row)
    }
  }
  process {
    for ($i = 0; $i -lt $raw.WindowSize.Height; $i++) {
      strip 0 $i ([Math]::Round(($pc.NextValue() * 100 / $raw.WindowSize.Width + 1))) 'Green'
      sleep -s 1
    }
  }
  end {
    cls
  }
#}

