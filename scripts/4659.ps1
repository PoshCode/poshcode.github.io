function RadialPoint([Int32]$radius, [Int32]$seconds) {
  $center = New-Object Drawing.Point(($this.ClientRectangle.Width / 2), ($this.ClientRectangle.Height / 2))
  [Double]$angle =- (($seconds - 15) % 60) * [Math]::PI / 30
  $ret = New-Object Drawing.Point(($center.X + [Int32]($radius * [Math]::Cos($angle))), `
                                    ($center.Y - [Int32]($radius * [Math]::Sin($angle))))
  return $ret
}

$frmMain_Paint= {
  $now = [DateTime]::Now
  $gfx = $this.CreateGraphics()
  $cnt = New-Object Drawing.Point(($this.ClientRectangle.Width / 2), ($this.ClientRectangle.Height / 2))
  $rad = [Math]::Min($this.ClientRectangle.Width, $this.ClientRectangle.Height) / 2
  #background
  $lgb = New-Object Drawing.Drawing2D.LinearGradientBrush($this.ClientRectangle, [Drawing.Color]::Linen, `
                     [Drawing.Color]::DarkGreen, [Drawing.Drawing2D.LinearGradientMode]::BackwardDiagonal)
  $gfx.FillEllipse($lgb, $cnt.X - $rad, $cnt.Y - $rad, $rad * 2, $rad * 2)
  #points
  for ($min = 0; $min -lt 60; $min++) {
    [Drawing.Point]$pnt = RadialPoint ($rad - 10) $min
    $sb = New-Object Drawing.SolidBrush([Drawing.Color]::Black)
    
    if (($min % 5) -eq 0) {
      $gfx.FillRectangle($sb, $pnt.X - 3, $pnt.Y - 3, 6, 6)
    }
    else {
      $gfx.FillRectangle($sb, $pnt.X - 1, $pnt.Y - 1, 2, 2)
    }
  }
  #pointers
  $hp = New-Object Drawing.Pen([Drawing.Color]::Black, 8)
  $mp = New-Object Drawing.Pen([Drawing.Color]::Black, 6)
  $sp = New-Object Drawing.Pen([Drawing.Color]::Red, 1)
  #tune and draw
  $hp, $mp | % {
    $_.StartCap = [Drawing.Drawing2D.LineCap]::Round
    $_.EndCap = [Drawing.Drawing2D.LineCap]::Round
  }
  $sp.CustomEndCap = New-Object Drawing.Drawing2D.AdjustableArrowCap(2, 3, $true)
  $pin = New-Object Drawing.SolidBrush([Drawing.Color]::Red)
  $gfx.DrawLine($hp, (RadialPoint 15 (30 + $now.Hour * 5 + $now.Minute / 12)), `
        (RadialPoint ([Int32]($rad * 0.55)) ($now.Hour * 5 + $now.Minute / 12)))
  $gfx.DrawLine($mp, (RadialPoint 15 (30 + $now.Minute)), (RadialPoint ([Int32]($rad * 0.8)) $now.Minute))
  $gfx.DrawLine($sp, (RadialPoint 20 ($now.Second + 30)), (RadialPoint ($rad - 2) $now.Second))
  $gfx.FillEllipse($pin, $cnt.X - 5, $cnt.Y - 5, 10, 10)
}

function frmMain_Show {
  Add-Type -Assembly System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()
  
  $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
  
  $frmMain = New-Object Windows.Forms.Form
  $tmrTick = New-Object Windows.Forms.Timer
  #
  #tmrTick
  #
  $tmrTick.Enabled = $true
  $tmrTick.Interval = 1000
  $tmrTick.Add_Tick({$frmMain.Invalidate()})
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(150, 150)
  $frmMain.FormBorderStyle = "FixedSingle"
  $frmMain.Icon = $ico
  $frmMain.MaximizeBox = $false
  $frmMain.MinimizeBox = $false
  $frmMain.StartPosition = "CenterScreen"
  $frmMain.Text = "PowerShell Clock"
  $frmMain.Add_Paint($frmMain_Paint)
  
  [void]$frmMain.ShowDialog()
}

frmMain_Show
