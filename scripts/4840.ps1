#requires -version 2.0
function Get-CurrentState {
  $k = 1
  for ($i = 0; $i -lt $pnt; $i++) {
    for ($j = 0; $j -lt $pnt; $j++) {
      if ($num[$i, $j] -ne $k) {return $false}
      $k++
    }
  }
  return $true
}

function frmMain_Show {
  Add-Type -AssemblyName System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()
  
  $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
  
  set pnt -val 4 -opt Constant
  set nul -val ($pnt * $pnt) -opt Constant
  
  $nulX = $nulY = $pnt - 1
  
  $btn = New-Object "Windows.Forms.Button[,]" 4, 4
  $num = New-Object "Int32[,]" 4, 4
  $rnd = New-Object Random
  $fnt = New-Object Drawing.Font("Tahoma", 14, [Drawing.FontStyle]::Bold)
  
  $frmMain = New-Object Windows.Forms.Form
  $mnuMain = New-Object Windows.Forms.MenuStrip
  $mnuGame = New-Object Windows.Forms.ToolStripMenuItem
  $mnuPlay = New-Object Windows.Forms.ToolStripMenuItem
  $mnuNull = New-Object Windows.Forms.ToolStripSeparator
  $mnuExit = New-Object Windows.Forms.ToolStripMenuItem
  $mnuHelp = New-Object Windows.Forms.ToolStripMenuItem
  $mnuInfo = New-Object Windows.Forms.ToolStripMenuItem
  $lblTime = New-Object Windows.Forms.Label
  $tmrTick = New-Object Windows.Forms.Timer
  $sbStrip = New-Object Windows.Forms.StatusStrip
  $sbLabel = New-Object Windows.Forms.ToolStripStatusLabel
  #
  #common
  #
  $mnuMain.Items.AddRange(@($mnuGame, $mnuHelp))
  $sbStrip.Items.AddRange(@($sbLabel))
  $sbLabel.AutoSize = $true
  #
  #mnuGame
  #
  $mnuGame.DropDownItems.AddRange(@($mnuPlay, $mnuNull, $mnuExit))
  $mnuGame.Text = "&Game"
  #
  #mnuPlay
  #
  $mnuPlay.ShortcutKeys = [Windows.Forms.Keys]::F5
  $mnuPlay.Text = "&New Game..."
  $mnuPlay.Add_Click({
    #mixing
    for ($k = 0; $k -lt 400; $k++) {
      $vec = $rnd.Next(4) #moving vector
    
      switch($vec) {
        "0" {
          if (($nulX - 1) -ge 0) {
            $num[$nulX, $nulY] = $num[($nulX - 1), $nulY]
            $nulX--
          }
          else {
            for ($i = 0; $i -lt ($pnt - 1); $i++) {
              $num[$i, $nulY] = $num[($i + 1), $nulY]
            }
            $nulX = $pnt - 1
          }
        }
        "1" {
          if (($nulX + 1) -lt $pnt) {
            $num[$nulX, $nulY] = $num[($nulX + 1), $nulY]
            $nulX++
          }
          else {
            for ($i = ($pnt - 1); $i -gt 0; $i--) {
              $num[$i, $nulY] = $num[($i - 1), $nulY]
            }
            $nulX = 0
          }
        }
        "2" {
          if (($nulY - 1) -ge 0) {
            $num[$nulX, $nulY] = $num[$nulX, ($nulY - 1)]
            $nulY--
          }
          else {
            for ($j = 0; $j -lt ($pnt - 1); $j++) {
              $num[$nulX, $j] = $num[$nulX, ($j + 1)]
            }
            $nulY = $pnt - 1
          }
        }
        default {
          if (($nulY + 1) -lt $pnt) {
            $num[$nulX, $nulY] = $num[$nulX, ($nulY + 1)]
            $nulY++
          }
          else {
            for ($j = ($pnt - 1); $j -gt 0; $j--) {
              $num[$nulX, $j] = $num[$nulX, ($j - 1)]
            }
            $nulY = 0
          }
        }
      } #switch
    
      $num[$nulX, $nulY] = $nul
    } #for
  
    #show new order
    for ($i = 0; $i -lt $pnt; $i++) {
      for ($j = 0; $j -lt $pnt; $j++) {
        if ($num[$i, $j] -ne $nul) {$btn[$i, $j].Text = $num[$i, $j]}
        else {$btn[$i, $j].Text = [String]::Empty}
      }
    }
  
    #game counters
    [UInt32]$mov = 0
    $spn = New-Object TimeSpan(0, 0, 0)
    $bln = $true
    $lblTime.Text = "00:00:00"
    $sbLabel.Text = "Moves: " + $mov
    $tmrTick.Start()
  })
  #
  #mnuExit
  #
  $mnuExit.ShortcutKeys = [Windows.Forms.Keys]::Control, [Windows.Forms.Keys]::X
  $mnuExit.Text = "E&xit"
  $mnuExit.Add_Click({$frmMain.Close()})
  #
  #mnuHelp
  #
  $mnuHelp.DropDownItems.AddRange(@($mnuInfo))
  $mnuHelp.Text = "&Help"
  #
  #mnuInfo
  #
  $mnuInfo.Text = "About..."
  $mnuInfo.Add_Click({
    $tmrTick.Stop()
    frmInfo_Show
  })
  #
  #lblTime
  #
  $lblTime.BackColor = [Drawing.Color]::Linen
  $lblTime.BorderStyle= [Windows.Forms.BorderStyle]::FixedSingle
  $lblTime.Font = $fnt
  $lblTime.Location = New-Object Drawing.Point(10, 30)
  $lblTime.Size = New-Object Drawing.Size(200, 20)
  $lblTime.Text = "00:00:00"
  $lblTime.TextAlign = [Drawing.ContentAlignment]::MiddleCenter
  #
  #tmrTick
  #
  $tmrTick.Enabled = $false
  $tmrTick.Interval = 1000
  $tmrTick.Add_Tick({
    $spn += New-Object TimeSpan(0, 0, 1)
    $lblTime.Text = $spn.ToString()
  })
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(220, 283)
  $frmMain.Controls.AddRange(@($lblTime, $sbStrip, $mnuMain))
  $frmMain.FormBorderStyle = [Windows.Forms.FormBorderStyle]::FixedSingle
  $frmMain.Icon = $ico
  $frmMain.MainMenuStrip = $mnuMain
  $frmMain.MaximizeBox = $false
  $frmMain.MinimizeBox = $false
  $frmMain.StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
  $frmMain.Text = "Fifteen"
  $frmMain.Add_Load({
    #create game field
    for ($i = 0; $i -lt $pnt; $i++) {
      for ($j = 0; $j -lt $pnt; $j++) {
        $btn[$i, $j] = New-Object Windows.Forms.Button
        $btn[$i, $j].Parent = $this #add button at form
        $num[$i, $j] = $i * 4 + $j + 1 #numbers order
        #space button condition
        if ($num[$i, $j] -ne 16) {$btn[$i, $j].Text = $num[$i, $j]}
        #position and style
        $btn[$i, $j].Left = 10 + $j * 50
        $btn[$i, $j].Top = 55 + $i * 50
        $btn[$i, $j].Size = New-Object Drawing.Size(50, 50)
        $btn[$i, $j].BackColor = [Drawing.Color]::Linen
        $btn[$i, $j].Font = $fnt
        #coordinates of button
        $btn[$i, $j].Tag = New-Object Drawing.Point($i, $j)
        #events
        $btn[$i, $j].Add_Click({
          if (!$bln) {return}
          [Int32]$i = $this.Tag.X
          [Int32]$j = $this.Tag.Y
          #step
          if (([Math]::Abs($i - $nulX) + [Math]::Abs($j - $nulY)) -eq 1) {
            $num[$nulX, $nulY] = $num[$i, $j]
            $btn[$nulX, $nulY].Text = $btn[$i, $j].Text #change button text
            #hew coordinates of null
            $nulX = $i
            $nulY = $j
            $num[$nulX, $nulY] = $nul
            $btn[$nulX, $nulY].Text = [String]::Empty
            #step is done
            $mov++
            $sbLabel.Text = "Moves: " + $mov
          }
          #is game over?
          if ($nulX -eq ($pnt - 1) -and $nulY -eq ($pnt - 1)) {
            if (Get-CurrentState) {$tmrTick.Stop()}
          }
        }) #events
      } #for
    } #for
    $sbLabel.Text = "Moves: 0"
  })
  
  [void]$frmMain.ShowDialog()
}

function frmInfo_Show {
  $frmInfo = New-Object Windows.Forms.Form
  $pbImage = New-Object Windows.Forms.PictureBox
  $lblName = New-Object Windows.Forms.Label
  $lblCopy = New-Object Windows.Forms.Label
  $btnExit = New-Object Windows.Forms.Button
  #
  #pbImage
  #
  $pbImage.Image = $ico.ToBitmap()
  $pbImage.Location = New-Object Drawing.Point(16, 16)
  $pbImage.Size = New-Object Drawing.Size(32, 32)
  $pbImage.SizeMode = [Windows.Forms.PictureBoxSizeMode]::StretchImage
  #
  #lblName
  #
  $lblName.Font = New-Object Drawing.Font("Microsoft Sans Serif", 8, [Drawing.FontStyle]::Bold)
  $lblName.Location = New-Object Drawing.Point(53, 19)
  $lblName.Size = New-Object Drawing.Size(360, 18)
  $lblName.Text = "Fifteen Game v1.01"
  #
  #lblCopy
  #
  $lblCopy.Location = New-Object Drawing.Point(67, 37)
  $lblCopy.Size = New-Object Drawing.Size(360, 23)
  $lblCopy.Text = "Copyright (C) 2013-2014 greg zakharov"
  #
  #btnExit
  #
  $btnExit.Location = New-Object Drawing.Point(135, 67)
  $btnExit.Text = "OK"
  $btnExit.Add_Click({
    if ($bln) {$tmrTick.Start()}
    if (Get-CurrentState) {$tmrTick.Stop()}
  })
  #
  #frmInfo
  #
  $frmInfo.AcceptButton = $btnExit
  $frmInfo.CancelButton = $btnExit
  $frmInfo.ClientSize = New-Object Drawing.Size(350, 110)
  $frmInfo.ControlBox = $false
  $frmInfo.Controls.AddRange(@($pbImage, $lblName, $lblCopy, $btnExit))
  $frmInfo.FormBorderStyle = [Windows.Forms.FormBorderStyle]::FixedSingle
  $frmInfo.ShowInTaskBar = $false
  $frmInfo.StartPosition = [Windows.Forms.FormStartPosition]::CenterParent
  $frmInfo.Text = "About..."

  [void]$frmInfo.ShowDialog()
}

frmMain_Show
