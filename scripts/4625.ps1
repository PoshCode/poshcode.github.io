#requires -version 2.0
function Get-UserStatus {
  $usr = [Security.Principal.WindowsIdentity]::GetCurrent()
  return (New-Object Security.Principal.WindowsPrincipal $usr).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
  )
}

function Get-ClassesList([String]$NameSpace, [String]$Filter) {
  gwmi -List -NameSpace $NameSpace $Filter | % {
    $lstLst1.Items.Add($_.Name)
  }
}

function Reset-DataLists {
  $lstLst2.Items.Clear()
  $lstLst3.Items.Clear()
  $lstLst4.Items.Clear()
  $sbLabel.Text = [String]::Empty
}

$mnuTStr_Click= {
  $toggle =! $mnuTStr.Checked
  $mnuTStr.Checked = $toggle
  $tsStrip.Visible = $toggle
}

$mnuSStr_Click= {
  $toggle =! $mnuSStr.Checked
  $mnuSStr.Checked = $toggle
  $sbStrip.Visible = $toggle
}

$tsCbo_1_SelectedIndexChanged= {
  if (Get-UserStatus) {
    $lstLst1.Items.Clear()
    Reset-DataLists
  
    switch ($tsCbo_1.SelectedIndex) {
      "0" {$tsCbo_2.Enabled = $false; $tsCbo_2.SelectedIndex = 0}
      "1" {$tsCbo_2.Enabled = $true}
    }
  
    Get-ClassesList $tsCbo_1.SelectedItem $tsCbo_2.SelectedItem
  }
}

$tsCbo_2_SelectedIndexChanged= {
  $lstLst1.Items.Clear()
  Reset-DataLists
  Get-ClassesList $tsCbo_1.SelectedItem $tsCbo_2.SelectedItem
}

$lstLst1_Click= {
  Reset-DataLists
  
  for ($i = 0; $i -lt $lstLst1.Items.Count; $i++) {
    if ($lstLst1.Items[$i].Selected) {
      $wmi = ([wmiclass]($tsCbo_1.SelectedItem + ':' + $lstLst1.Items[$i].Text)).PSBase
      
      $sbLabel.Text = "Path: " + $wmi.Path.Path
    
      $wmi.Methods | % {
        $itm = $lstLst2.Items.Add($_.Name)
        $itm.SubItems.Add($_.Origin)
        try {
          $itm.SubItems.Add($_.Qualifiers["Description"].Value)
        }
        catch {
          $itm.SubItems.Add([String]::Empty)
        }
      }
      
      $wmi.Properties | % {
        $itm = $lstLst3.Items.Add($_.Name)
        $itm.SubItems.Add($_.Type.ToString())
        $itm.SubItems.Add($_.IsLocal.ToString())
        $itm.SubItems.Add($_.IsArray.ToString())
        try {
          $itm.SubItems.Add($_.Qualifiers["Description"].Value)
        }
        catch {
          $itm.SubItems.Add([String]::Empty)
        }
      }
      
      $wmi.Qualifiers | % {
        $itm = $lstLst4.Items.Add($_.Name)
        $itm.SubItems.Add($_.Value.ToString())
        $itm.SubItems.Add($_.IsAmended.ToString())
        $itm.SubItems.Add($_.IsLocal.ToString())
        $itm.SubItems.Add($_.IsOverridable.ToString())
        $itm.SubItems.Add($_.PropagatesToInstance.ToString())
        $itm.SubItems.Add($_.PropagatesToSubclass.ToString())
      }
    }
  }
}

$frmMain_Load= {
  if (Get-UserStatus) {
    Get-ClassesList $tsCbo_1.SelectedItem $tsCbo_2.SelectedItem
  }
  else {
    $sbLabel.Font = New-Object Drawing.Font("Microsoft Sans Serif", 8.5, [Drawing.FontStyle]::Bold)
    $sbLabel.ForeColor = "Crimson"
    $sbLabel.Text = "You haven't enought rights to access WMI."
  }
}

function frmMain_Show {
  Add-Type -Assembly System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()
  
  $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
  
  $frmMain = New-Object Windows.Forms.Form
  $mnuMain = New-Object Windows.Forms.MenuStrip
  $mnuFile = New-Object Windows.Forms.ToolStripMenuItem
  $mnuExit = New-Object Windows.Forms.ToolStripMenuItem
  $mnuView = New-Object Windows.Forms.ToolStripMenuItem
  $mnuTStr = New-Object Windows.Forms.ToolStripMenuItem
  $mnuSStr = New-Object Windows.Forms.ToolStripMenuItem
  $mnuHelp = New-Object Windows.Forms.ToolStripMenuItem
  $mnuInfo = New-Object Windows.Forms.ToolStripMenuItem
  $tsStrip = New-Object Windows.Forms.ToolStrip
  $tsLbl_1 = New-Object Windows.Forms.ToolStripLabel
  $tsLbl_2 = New-Object Windows.Forms.ToolStripLabel
  $tsCbo_1 = New-Object Windows.Forms.ToolStripComboBox
  $tsCbo_2 = New-Object Windows.Forms.ToolStripComboBox
  $tsSepar = New-Object Windows.Forms.ToolStripSeparator
  $scSplit = New-Object Windows.Forms.SplitContainer
  $lstLst1 = New-Object Windows.Forms.ListView
  $lstLst2 = New-Object Windows.Forms.ListView
  $lstLst3 = New-Object Windows.Forms.ListView
  $lstLst4 = New-Object Windows.Forms.ListView
  $chCol_1 = New-Object Windows.Forms.ColumnHeader
  $chCol_2 = New-Object Windows.Forms.ColumnHeader
  $chCol_3 = New-Object Windows.Forms.ColumnHeader
  $chCol_4 = New-Object Windows.Forms.ColumnHeader
  $chCol_5 = New-Object Windows.Forms.ColumnHeader
  $chCol_6 = New-Object Windows.Forms.ColumnHeader
  $chCol_7 = New-Object Windows.Forms.ColumnHeader
  $chCol_8 = New-Object Windows.Forms.ColumnHeader
  $chCol_9 = New-Object Windows.Forms.ColumnHeader
  $chCol10 = New-Object Windows.Forms.ColumnHeader
  $chCol11 = New-Object Windows.Forms.ColumnHeader
  $chCol12 = New-Object Windows.Forms.ColumnHeader
  $chCol13 = New-Object Windows.Forms.ColumnHeader
  $chCol14 = New-Object Windows.Forms.ColumnHeader
  $chCol15 = New-Object Windows.Forms.ColumnHeader
  $chCol16 = New-Object Windows.Forms.ColumnHeader
  $tabCtrl = New-Object Windows.Forms.TabControl
  $tpPage1 = New-Object Windows.Forms.TabPage
  $tpPage2 = New-Object Windows.Forms.TabPage
  $tpPage3 = New-Object Windows.Forms.TabPage
  $sbStrip = New-Object Windows.Forms.StatusStrip
  $sbLabel = New-Object Windows.Forms.ToolStripStatusLabel
  #
  #mnuMain
  #
  $mnuMain.Items.AddRange(@($mnuFile, $mnuView, $mnuHelp))
  #
  #mnuFile
  #
  $mnuFile.DropDownItems.AddRange(@($mnuExit))
  $mnuFile.Text = "&File"
  #
  #mnuExit
  #
  $mnuExit.ShortcutKeys = "Control", "X"
  $mnuExit.Text = "E&xit"
  $mnuExit.Add_Click({$frmMain.Close()})
  #
  #mnuView
  #
  $mnuView.DropDownItems.AddRange(@($mnuTStr, $mnuSStr))
  $mnuView.Text = "&View"
  #
  #mnuTStr
  #
  $mnuTStr.Checked = $true
  $mnuTStr.ShortcutKeys = "Control", "T"
  $mnuTStr.Text = "&Tools Panel"
  $mnuTStr.Add_Click($mnuTStr_Click)
  #
  #mnuSStr
  #
  $mnuSStr.Checked = $true
  $mnuSStr.Text = "&Status Bar"
  $mnuSStr.Add_Click($mnuSStr_Click)
  #
  #mnuHelp
  #
  $mnuHelp.DropDownItems.AddRange(@($mnuInfo))
  $mnuHelp.Text = "&Help"
  #
  #mnuInfo
  #
  $mnuInfo.Text = "About..."
  $mnuInfo.Add_Click({frmInfo_Show})
  #
  #tsStrip
  #
  $tsStrip.Items.AddRange(@($tsLbl_1, $tsCbo_1, $tsSepar, $tsLbl_2, $tsCbo_2))
  #
  #tsLbl_1
  #
  $tsLbl_1.Text = "NameSpace:"
  #
  #tsCbo_1
  #
  $tsCbo_1.Items.AddRange(@('root\default', 'root\cimv2'))
  $tsCbo_1.SelectedIndex = 0
  $tsCbo_1.Add_SelectedIndexChanged($tsCbo_1_SelectedIndexChanged)
  #
  #tsLbl_2
  #
  $tsLbl_2.Text = "Filter:"
  #
  #tsCbo_2
  #
  $tsCbo_2.Enabled = $false
  $tsCbo_2.Items.AddRange(@('*', 'Win32_*'))
  $tsCbo_2.SelectedIndex = 0
  $tsCbo_2.Add_SelectedIndexChanged($tsCbo_2_SelectedIndexChanged)
  #
  #scSplit
  #
  $scSplit.Dock = "Fill"
  $scSplit.Panel1.Controls.Add($lstLst1)
  $scSplit.Panel2.Controls.Add($tabCtrl)
  $scSplit.SplitterWidth = 1
  #
  #lstLst1
  #
  $lstLst1.Columns.AddRange(@($chCol_1))
  $lstLst1.Dock = "Fill"
  $lstLst1.FullRowSelect = $true
  $lstLst1.MultiSelect = $false
  $lstLst1.ShowItemToolTips = $true
  $lstLst1.Sorting = "Ascending"
  $lstLst1.View = "Details"
  $lstLst1.Add_Click($lstLst1_Click)
  #
  #chCol_1
  #
  $chCol_1.Text = "Classes"
  $chCol_1.Width = 240
  #
  #tabCtrl
  #
  $tabCtrl.Controls.AddRange(@($tpPage1, $tpPage2, $tpPage3))
  $tabCtrl.Dock = "Fill"
  #
  #tpPage1
  #
  $tpPage1.Controls.AddRange(@($lstLst2))
  $tpPage1.Text = "Methods"
  $tpPage1.UseVisualStyleBackColor = $true
  #
  #lstLst2
  #
  $lstLst2.Columns.AddRange(@($chCol_2, $chCol_3, $chCol_4))
  $lstLst2.Dock = "Fill"
  $lstLst2.FullRowSelect = $true
  $lstLst2.MultiSelect = $false
  $lstLst2.ShowItemToolTips = $true
  $lstLst2.View = "Details"
  #
  #chCol_2
  #
  $chCol_2.Text = "Method"
  $chCol_2.Width = 170
  #
  #chCol_3
  #
  $chCol_3.Text = "Origin"
  $chCol_3.Width = 130
  #
  #chCol_4
  #
  $chCol_4.Text = "Description"
  $chCol_4.Width = 200
  #
  #tpPage2
  #
  $tpPage2.Controls.AddRange(@($lstLst3))
  $tpPage2.Text = "Properties"
  $tpPage2.UseVisualStyleBackColor = $true
  #
  #lstLst3
  #
  $lstLst3.Columns.AddRange(@($chCol_5, $chCol_6, $chCol_7, $chCol_8, $chCol_9))
  $lstLst3.Dock = "Fill"
  $lstLst3.FullRowSelect = $true
  $lstLst3.MultiSelect = $false
  $lstLst3.ShowItemToolTips = $true
  $lstLst3.View = "Details"
  #
  #chCol_5
  #
  $chCol_5.Text = "Property"
  $chCol_5.Width = 150
  #
  #chCol_6
  #
  $chCol_6.Text = "Type"
  $chCol_6.Width = 50
  #
  #chCol_7
  #
  $chCol_7.Text = "IsLocal"
  $chCol_7.Width = 50
  #
  #chCol_8
  #
  $chCol_8.Text = "IsArray"
  $chCol_8.Width = 50
  #
  #chCol_9
  #
  $chCol_9.Text = "Description"
  $chCol_9.Width = 200
  #
  #tpPage3
  #
  $tpPage3.Controls.AddRange(@($lstLst4))
  $tpPage3.Text = "Qualifiers"
  $tpPage3.UseVisualStyleBackColor = $true
  #
  #lstLst4
  #
  $lstLst4.Columns.AddRange(@($chCol10, $chCol11, $chCol12, $chCol13, $chCol14, $chCol15, $chCol16))
  $lstLst4.Dock = "Fill"
  $lstLst4.FullRowSelect = $true
  $lstLst4.MultiSelect = $false
  $lstLst4.ShowItemToolTips = $true
  $lstLst4.View = "Details"
  #
  #chCol10
  #
  $chCol10.Text = "Name"
  $chCol10.Width = 70
  #
  #chCol11
  #
  $chCol11.Text = "Value"
  $chCol11.Width = 100
  #
  #chCol12
  #
  $chCol12.Text = "IsAmended"
  $chCol12.Width = 70
  #
  #chCol13
  #
  $chCol13.Text = "IsLocal"
  $chCol13.Width = 50
  #
  #chCol14
  #
  $chCol14.Text = "IsOverridable"
  $chCol14.Width = 80
  #
  #chCol15
  #
  $chCol15.Text = "PropagatesToInstance"
  $chCol15.Width = 120
  #
  #chCol16
  #
  $chCol16.Text = "PropagatesToSubclass"
  $chCol16.Width = 127
  #
  #sbStrip
  #
  $sbStrip.Items.AddRange(@($sbLabel))
  #
  #sbLabel
  #
  $sbLabel.AutoSize = $true
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(800, 545)
  $frmMain.Controls.AddRange(@($scSplit, $sbStrip, $tsStrip, $mnuMain))
  $frmMain.Icon = $ico
  $frmMain.MainMenuStrip = $mnuMain
  $frmMain.StartPosition = "CenterScreen"
  $frmMain.Text = "WMI Explorer"
  $frmMain.Add_Load($frmMain_Load)
  
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
  $pbImage.SizeMode = "StretchImage"
  #
  #lblName
  #
  $lblName.Font = New-Object Drawing.Font("Microsoft Sans Serif", 9, [Drawing.FontStyle]::Bold)
  $lblName.Location = New-Object Drawing.Point(53, 19)
  $lblName.Size = New-Object Drawing.Size(360, 18)
  $lblName.Text = "WMI Explorer v1.00"
  #
  #lblCopy
  #
  $lblCopy.Location = New-Object Drawing.Point(67, 37)
  $lblCopy.Size = New-Object Drawing.Size(360, 23)
  $lblCopy.Text = "(C) 2013 greg zakharov forum.script-coding.com"
  #
  #btnExit
  #
  $btnExit.Location = New-Object Drawing.Point(135, 67)
  $btnExit.Text = "OK"
  #
  #frmInfo
  #
  $frmInfo.AcceptButton = $btnExit
  $frmInfo.CancelButton = $btnExit
  $frmInfo.ClientSize = New-Object Drawing.Size(350, 110)
  $frmInfo.ControlBox = $false
  $frmInfo.Controls.AddRange(@($pbImage, $lblName, $lblCopy, $btnExit))
  $frmInfo.FormBorderStyle = "FixedSingle"
  $frmInfo.ShowInTaskBar = $false
  $frmInfo.StartPosition = "CenterParent"
  $frmInfo.Text = "About..."
  $frmInfo.Add_Load($frmInfo_Load)

  [void]$frmInfo.ShowDialog()
}

frmMain_Show
