function frmMain_Show([String]$card) {
  Add-Type -Assembly System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()
  
  $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
  $fnt = New-Object Drawing.Font("Tahoma", 10, [Drawing.FontStyle]::Bold)
  $scr = [Windows.Forms.Screen]::PrimaryScreen.Bounds
  
  $rec = New-Object Diagnostics.PerformanceCounter("Network Interface", "Bytes Received/Sec", $card)
  $sen = New-Object Diagnostics.PerformanceCounter("Network Interface", "Bytes Sent/Sec", $card)
  #begin invoke
  [void]'{0} {1}' -f $rec.NextValue(), $sen.NextValue()
  
  $frmMain = New-Object Windows.Forms.Form
  $lblLbl1 = New-Object Windows.Forms.Label
  $lblLbl2 = New-Object Windows.Forms.Label
  $mnuIcon = New-Object Windows.Forms.ContextMenu
  $mnuExit = New-Object Windows.Forms.MenuItem
  $niPopup = New-Object Windows.Forms.NotifyIcon
  $tmrTick = New-Object Windows.Forms.Timer
  #
  #common
  #
  $lblLbl1, $lblLbl2 | % {$_.Font = $fnt}
  $mnuIcon.MenuItems.AddRange(@($mnuExit))
  #
  #lblLbl1
  #
  $lblLbl1.ForeColor = [Drawing.Color]::FromArgb(0, 0, 255)
  $lblLbl1.Height = 19
  $lblLbl1.Location = New-Object Drawing.Point(7, 7)
  $lblLbl1.Text = "Recieved"
  #
  #lblLbl2
  #
  $lblLbl2.ForeColor = [Drawing.Color]::FromArgb(255, 0, 128)
  $lblLbl2.Location = New-Object Drawing.Point(7, 25)
  $lblLbl2.Text = "Sent"
  #
  #mnuExit
  #
  $mnuExit.Text = "E&xit"
  $mnuExit.Add_Click({$niPopup.Visible = $false;$frmMain.Close()})
  #
  #niPopup
  #
  $niPopup.ContextMenu = $mnuIcon
  $niPopup.Icon = $ico
  $niPopup.Text = "NetSpeed Monitor"
  $niPopup.Visible = $true
  #
  #tmrTick
  #
  $tmrTick.Enabled = $true
  $tmrTick.Interval = 1000
  $tmrTick.Add_Tick({
    $lblLbl1.Text = ('R: {0:f2} Kb/s' -f ([Math]::Floor($rec.NextValue()) / 1024))
    $lblLbl2.Text = ('S: {0:f2} Kb/s' -f ([Math]::Floor($sen.NextValue()) / 1024))
  })
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(100, 47)
  $frmMain.Controls.AddRange(@($lblLbl1, $lblLbl2))
  $frmMain.FormBorderStyle = [Windows.Forms.FormBorderStyle]::None
  $frmMain.Icon = $ico
  $frmMain.Location = New-Object Drawing.Point(($scr.Width - 115), ($scr.Height - 81))
  $frmMain.Opacity = .7
  $frmMain.ShowInTaskbar = $false
  $frmMain.StartPosition = [Windows.Forms.FormStartPosition]::Manual
  $frmMain.Text = "NetSpeed Monitor"
  $frmMain.TopMost = $true
  
  [void]$frmMain.ShowDialog()
}

$ins = (New-Object Diagnostics.PerformanceCounterCategory("Network Interface")).GetInstanceNames()
#input correct item, for me it'll be...
frmMain_Show $ins[1]
