Set-Alias gpg Get-ProcessorGraph

function Get-ProcessorGraph {
  <#
    .EXAMPLE
        PS C:\>Get-ProcessorGraph
        Monitors CPU fifteen seconds.
    .EXAMPLE
        PS C:\>gpg -g Red -w 25
        Sets red color for graph and monitors CPU 25 seconds.
  #>
  param(
    [Parameter(Position=0)]
    [Alias("w")]
    [ValidateRange(10, 1000000)]
    [Int32]$WatchTime = 15,
    
    [Parameter(Position=1)]
    [ConsoleColor]$GraphColor = 'Green'
  )
  
  begin {
    $pc = New-Object Diagnostics.PerformanceCounter("Processor", "% Processor Time", "_Total")

    $raw = $host.UI.RawUI
    $old = $raw.WindowPosition
    $con = $raw.WindowSize
    $rec = New-Object Management.Automation.Host.Rectangle $old.X, $old.Y, `
                                        $raw.BufferSize.Width, ($old.Y + 25)
    $buf = $raw.GetBufferContents($rec)
    
    function strip([Int32]$x, [Int32]$y, [Int32]$z, [ConsoleColor]$bc) {
      $pos = $old;$pos.X += $x;$pos.Y += $y
      $row = $raw.NewBufferCellArray(@(' ' * $z), $bc, $bc)
      $raw.SetBufferContents($pos, $row)
    }
    
    function msg([Int32]$x, [Int32]$y, [String]$text, [ConsoleColor]$fc, [ConsoleColor]$bc) {
      $pos = $old;$pos.X += $x;$pos.Y += $y
      $row = $raw.NewBufferCellArray(@($text), $fc, $bc)
      $raw.SetBufferContents($pos, $row)
    }
  }
  process {
    $i = $WatchTime
    while ($i -gt 0) {
      msg 0 1 "CPU Usage" 'Gray' 'DarkYellow'
      strip 9 1 ([Math]::Round(($pc.NextValue() * 100 / $con.Width + 1))) $GraphColor
      sleep -s 1
      $i--
      $raw.SetBufferContents($old, $buf)
    }
  }
  end {
  }
}
