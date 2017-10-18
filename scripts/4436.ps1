if ($host.Runspace.ApartmentState -ne "STA") {
  powershell /noprofile /sta $MyInvocation.MyCommand.Path
  return
}

$dir = (gci $MyInvocation.MyCommand.Name).Directory
$iam = [Security.Principal.WindowsIdentity]::GetCurrent().Name
$key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'

function ItemsCounting {
  $sbLabel.Text = $lstView.Items.Count.ToString() + " item(s)"
}

function BuildItemsList([string]$sid) {
  $str = (gp ($key + '\' + $sid)).ProfileImagePath
  $acc = ([Security.Principal.SecurityIdentifier]($sid)).Translate([Security.Principal.NTAccount]).Value
  
  $itm = $lstView.Items.Add($sid, 0)
  $itm.Subitems.Add((Split-Path -leaf $str))
  $itm.Subitems.Add($acc)
  $itm.Subitems.Add($str)
  
  if ($iam -eq $acc) { $itm.ForeColor = "Teal" }
}

function ShowProfilesList {
  $lstView.Items.Clear()
  
  switch ($mnuOnly.Checked) {
    $true {
      [Microsoft.Win32.Registry]::Users.GetSubKeyNames() `
      -notmatch '(Classes|.DEFAULT)'| % { BuildItemsList($_) }
    }
    $false {
      gci $key | % { BuildItemsList($_.PSChildName) }
    }
  }#switch
}

$mnuSave_Click= {
  if ($lstView.Items.Count -ne 0) {
    (New-Object Windows.Forms.SaveFileDialog) | % {
      $_.Filename = "Profiles"
      $_.Filter = "CSV (*.csv)|*.csv"
      $_.InitialDirectory = $dir

      if ($_.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
        if (-not (Test-Path $_.FileName)) {
          $sw = New-Object IO.StreamWriter($_.FileName, [Text.Encoding]::Deafault)
          $sw.WriteLine("SID, User Name, Account, Profile Path")
          $lstView.Items | % {
            $sw.WriteLine($($_.Text + ', ' + $_.SubItems[1].Text + ', ' + `
                                $_.SubItems[2].Text + ', ' + $_.SubItems[3].Text))
          }
          $sw.Flush()
          $sw.Close()
        }#file exist
      }#result
    }#dialog
  }#if
}

$mnuCopy_Click= {
  for ([int]$i = 0; $i -lt $lstView.Items.Count; $i++) {
    if ($lstView.Items[$i].Selected) {
      [Windows.Forms.Clipboard]::SetText($lstView.Items[$i].Text)
    }
  }#for
}

$mnuOnly_Click= {
  [bool]$tgl =! $mnuOnly.Checked
  $mnuOnly.Checked = $tgl
  
  ShowProfilesList
  ItemsCounting
}

$mnuSBar_Click= {
  [bool]$tgl =! $mnuSbar.Checked
  $mnuSbar.Checked = $tgl
  $sbStrip.Visible = $tgl
}

$mnuFont_Click= {
  (New-Object Windows.Forms.FontDialog) | % {
    $_.MaxSize = 12
    $_.ShowEffects = $false
    
    if ($_.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
      $lstView.Font = $_.Font
    }#if
  }#for each
}

function frmMain_Show {
  Add-Type -Assembly System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()
  
  $ico = [Drawing.Icon]::ExtractAssociatedIcon($pshome + "\powershell.exe")
  
  $frmMain = New-Object Windows.Forms.Form
  $mnuMain = New-Object Windows.Forms.MenuStrip
  $mnuFile = New-Object Windows.Forms.ToolStripMenuItem
  $mnuScan = New-Object Windows.Forms.ToolStripmenuItem
  $mnuCopy = New-Object Windows.Forms.ToolStripMenuItem
  $mnuSave = New-Object Windows.Forms.ToolStripMenuItem
  $mnuNul1 = New-Object Windows.Forms.ToolStripSeparator
  $mnuExit = New-Object Windows.Forms.ToolStripMenuItem
  $mnuView = New-Object Windows.Forms.ToolStripMenuItem
  $mnuOnly = New-Object Windows.Forms.ToolStripmenuItem
  $mnuSBar = New-Object Windows.Forms.ToolStripMenuItem
  $mnuNul2 = New-Object Windows.Forms.ToolStripSeparator
  $mnuFont = New-Object Windows.Forms.ToolStripMenuItem
  $mnuHelp = New-Object Windows.Forms.ToolStripMenuItem
  $mnuInfo = New-Object Windows.Forms.ToolStripMenuItem
  $lstView = New-Object Windows.Forms.ListView
  $imgList = New-Object Windows.Forms.ImageList
  $chSIDs_ = New-Object Windows.Forms.ColumnHeader
  $chNames = New-Object Windows.Forms.ColumnHeader
  $chNTAcc = New-Object Windows.Forms.ColumnHeader
  $chPaths = New-Object Windows.Forms.ColumnHeader
  $sbStrip = New-Object Windows.Forms.StatusStrip
  $sbLabel = New-Object Windows.Forms.ToolStripStatusLabel
  #
  #mnuMain
  #
  $mnuMain.Items.AddRange(@($mnuFile, $mnuView, $mnuHelp))
  #
  #mnuFile
  #
  $mnuFile.DropDownItems.AddRange(@($mnuScan, $mnuCopy, $mnuSave, $mnuNul1, $mnuExit))
  $mnuFile.Text = "&File"
  #
  #mnuScan
  #
  $mnuScan.ShortcutKeys = "F5"
  $mnuScan.Text = "S&can"
  $mnuScan.Add_Click({ShowProfilesList; ItemsCounting})
  #
  #mnuSave
  #
  $mnuSave.ShortcutKeys = "Control, S"
  $mnuSave.Text = "&Save"
  $mnuSave.Add_Click($mnuSave_Click)
  #
  #mnuCopy
  #
  $mnuCopy.ShortcutKeys = "Control, C"
  $mnuCopy.Text = "&Copy SID"
  $mnuCopy.Add_Click($mnuCopy_Click)
  #
  #mnuExit
  #
  $mnuExit.ShortcutKeys = "Control, X"
  $mnuExit.Text = "E&xit"
  $mnuExit.Add_Click({$frmMain.Close()})
  #
  #mnuView
  #
  $mnuView.DropDownItems.AddRange(@($mnuOnly, $mnuSBar, $mnuNul2, $mnuFont))
  $mnuView.Text = "&View"
  #
  #mnuOnly
  #
  $mnuOnly.Checked = $true
  $mnuOnly.ShortcutKeys = "Control, L"
  $mnuOnly.Text = "Only &Loaded"
  $mnuOnly.Add_Click($mnuOnly_Click)
  #
  #mnuSBar
  #
  $mnuSBar.Checked = $true
  $mnuSBar.ShortcutKeys = "Control, B"
  $mnuSBar.Text = "Show Status &Bar"
  $mnuSBar.Add_Click($mnuSbar_Click)
  #
  #mnuFont
  #
  $mnuFont.Text = "&Font..."
  $mnuFont.Add_Click($mnuFont_Click)
  #
  #mnuHelp
  #
  $mnuHelp.DropDownItems.AddRange(@($mnuInfo))
  $mnuHelp.Text = "&Help"
  #
  #mnuInfo
  #
  $mnuInfo.Text = "About"
  $mnuInfo.Add_Click({frmAbout_Show})
  #
  #lstView
  #
  $lstView.AllowColumnReorder = $true
  $lstView.Columns.AddRange(@($chSIDs_, $chNames, $chNTAcc, $chPaths))
  $lstView.Dock = "Fill"
  $lstView.FullRowSelect = $true
  $lstView.MultiSelect = $false
  $lstView.SmallImageList = $imgList
  $lstView.ShowItemToolTips = $true
  $lstView.Sorting = "Ascending"
  $lstView.View = "Details"
  #
  #imgList
  #
  $imgList.ColorDepth = "Depth32Bit"
  $imgList.Images.Add($ico.ToBitmap())
  $imgList.ImageSize = New-Object Drawing.Size(17, 15)
  #
  #chSIDs_
  #
  $chSIDs_.Text = "SID"
  $chSIDs_.Width = 75 #195
  #
  #chNames
  #
  $chNames.Text = "User Name"
  $chNames.Width = 90 #100
  #
  #chNTAcc
  #
  $chNTAcc.Text = "Account"
  $chNTAcc.Width = 143
  #
  #chPaths
  #
  $chPaths.Text = "Profile Path"
  $chPaths.Width = 260 #273
  #
  #sbStrip
  #
  $sbStrip.Items.AddRange(@($sbLabel))
  $sbStrip.SizingGrip = $false
  #
  #sbLabel
  #
  $sbLabel.Alignment = "Left"
  $sbLabel.BorderStyle = "Raised"
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(573, 217)
  $frmMain.Controls.AddRange(@($lstView, $sbStrip, $mnuMain))
  $frmMain.Icon = $ico
  $frmMain.MainMenuStrip = $mnuMain
  $frmMain.MaximizeBox = $false
  $frmMain.StartPosition = "CenterScreen"
  $frmMain.Text = "Profiles"
  $frmMain.Add_load({ItemsCounting})
  
  [void]$frmMain.ShowDialog()
}

function frmAbout_Show {
  $frmMain = New-Object Windows.Forms.Form
  $pbImage = New-Object Windows.Forms.PictureBox
  $lblName = New-Object Windows.Forms.Label
  $lblCopy = New-Object Windows.Forms.Label
  $btnExit = New-Object Windows.Forms.Button
  #
  #pbImage
  #
  $pbImage.Location = New-Object Drawing.Point(16, 16)
  $pbImage.Size = New-Object Drawing.Size(32, 32)
  $pbImage.SizeMode = "StretchImage"
  #
  #lblName
  #
  $lblName.Font = New-Object Drawing.Font("Microsoft Sans Serif", 8.5, [Drawing.FontStyle]::Bold)
  $lblName.Location = New-Object Drawing.Point(53, 19)
  $lblName.Size = New-Object Drawing.Size(360, 18)
  $lblName.Text = "Profiles v1.00"
  #
  #lblCopy
  #
  $lblCopy.Location = New-Object Drawing.Point(67, 37)
  $lblCopy.Size = New-Object Drawing.Size(360, 15)
  $lblCopy.Text = "Copyright (C) 2013 gregzakh@gmail.com"
  #
  #btnExit
  #
  $btnExit.Location = New-Object Drawing.Point(135, 57)
  $btnExit.Text = "OK"
  #
  #frmMain
  #
  $frmMain.AcceptButton = $btnExit
  $frmMain.CancelButton = $btnExit
  $frmMain.ClientSize = New-Object Drawing.Size(350, 90)
  $frmMain.ControlBox = $false
  $frmMain.Controls.AddRange(@($pbImage, $lblName, $lblCopy, $btnExit))
  $frmMain.FormBorderStyle = "FixedSingle"
  $frmMain.ShowInTaskbar = $false
  $frmMain.StartPosition = "CenterParent"
  $frmMain.Text = "About..."
  $frmMain.Add_Load({$pbImage.Image = $ico.ToBitmap()})
  
  [void]$frmMain.ShowDialog()
}

frmMain_Show
