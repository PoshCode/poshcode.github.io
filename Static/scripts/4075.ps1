#Require 2.0

$def = [Environment]::CurrentDirectory

##################################################################################################

$mnuOpen_Click= {
  (New-Object Windows.Forms.OpenFileDialog) | % {
    $_.FileName = "source"
    $_.Filter = "C# (*.cs)|*.cs"
    $_.InitialDirectory = $def

    if ($_.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
      $sr = New-Object IO.StreamReader $_.FileName
      $txtEdit.Text = $sr.ReadToEnd()
      $sr.Close()
    }
  }
}

$mnuFont_Click= {
  (New-Object Windows.Forms.FontDialog) | % {
    $_.Font = "Lucida Console"
    $_.MinSize = 10
    $_.MaxSize = 12
    $_.ShowEffects = $false

    if ($_.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
      $txtEdit.Font = $_.Font
    }
  }
}

$mnuOpaF_Click= {
  $frmMain.Opacity = 1
  $cur.Checked = $false
  $mnuOpaF.Checked = $true
  $cur = $mnuOpaF
}

$mnuWrap_Click= {
  $toggle =! $mnuWrap.Checked
  $mnuWrap.Checked = $toggle
  $txtEdit.WordWrap = $toggle
}

$tbTools_ButtonClick= {
  switch ($_.Button.Tag) {
    "Atom"     { Invoke-Atom; break }
    "Progress" { Show-Panel $mnuToS1 $scSplt1; break }
    "Params"   { Show-Panel $mnuToS2 $scSplt2; break }
    "Build"    { Invoke-Builder; break }
    "BuildEx"  { Start-AfterBuilding; break }
    "Exit"     { $frmMain.Close(); break }
  }
}

$cboPlat_SelectedIndexChanged= {
  switch ($cboPlat.SelectedIndex) {
    "0" { $lboRefs.Items.Remove("`"System.Core.dll`""); break }
    "1" { $lboRefs.Items.Add("`"System.Core.dll`""); break }
  }
}

$chkExec_Click= {
  switch ($chkExec.Checked) {
    $true  {
      $txtIOut.Text = $def + '\app.exe'
      $chkWApp.Enabled = $true
      $chkIMem.Enabled = $false
      $mnuBnRA.Enabled = $true
      $btnBnRA.Enabled = $true
      break
    }
    $false {
      $txtIOut.Text = $def + '\lib.dll'
      $chkWApp.Enabled = $false
      $chkIMem.Enabled = $true
      $mnuBnRA.Enabled = $false
      $btnBnRA.Enabled = $false
      break
    }
  }
}

$chkWApp_Click= {
  switch ($chkWApp.Checked) {
    $true  {
      $lboRefs.Items.AddRange(@("`"System.Drawing.dll`"", "`"System.Windows.Forms.dll`""))
      break
    }
    $false {
      $lboRefs.Items.Remove("`"System.Windows.Forms.dll`"")
      $lboRefs.Items.Remove("`"System.Drawing.dll`"")
      break
    }
  }
}

$mnuICnM_Click= {
  $script:buff = $lboRefs.SelectedItem
  $lboRefs.Items.Remove($lboRefs.SelectedItem)
}

$mnuIIns_Click= {
  (New-Object Windows.Forms.OpenFileDialog) | % {
    $_.Filter = "PE File (*.dll)|*.dll"
    $_.InitialDirectory = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()

    if ($_.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
      $lboRefs.Items.Add('"' + (Split-Path -leaf $_.FileName) + '"')
    }
  }
}

$frmMain_Load= {
  $txtIOut.Text = $def + '\app.exe'
  $sbPnl_2.Text = "Str: 1, Col: 0"
  $lboRefs.Items.Add("`"System.dll`"")
}

##################################################################################################

function frmMain_Show {
  Add-Type -AssemblyName System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()

  $ico = [Drawing.Icon]::ExtractAssociatedIcon($($PSHome + '\powershell_ise.exe'))

  $cdcp = New-Object CodeDom.Compiler.CompilerParameters
  $dict = New-Object "Collections.Generic.Dictionary[String, String]"
  $dict.Add("CompilerVersion", "v3.5")

  $frmMain = New-Object Windows.Forms.Form
  $mnuMain = New-Object Windows.Forms.MainMenu
  $mnuFile = New-Object Windows.Forms.MenuItem
  $mnuAtom = New-Object Windows.Forms.MenuItem
  $mnuOpen = New-Object Windows.Forms.MenuItem
  $mnuEmp1 = New-Object Windows.Forms.MenuItem
  $mnuExit = New-Object Windows.Forms.MenuItem
  $mnuEdit = New-Object Windows.Forms.MenuItem
  $mnuUndo = New-Object Windows.Forms.MenuItem
  $mnuEmp2 = New-Object Windows.Forms.MenuItem
  $mnuCopy = New-Object Windows.Forms.MenuItem
  $mnuPast = New-Object Windows.Forms.MenuItem
  $mnuICut = New-Object Windows.Forms.MenuItem
  $mnuEmp3 = New-Object Windows.Forms.MenuItem
  $mnuSAll = New-Object Windows.Forms.MenuItem
  $mnuView = New-Object Windows.Forms.MenuItem
  $mnuFont = New-Object Windows.Forms.MenuItem
  $mnuEmp4 = New-Object Windows.Forms.MenuItem
  $mnuOpac = New-Object Windows.Forms.MenuItem
  $mnuOp50 = New-Object Windows.Forms.MenuItem
  $mnuOp60 = New-Object Windows.Forms.MenuItem
  $mnuOp70 = New-Object Windows.Forms.MenuItem
  $mnuOp80 = New-Object Windows.Forms.MenuItem
  $mnuOp90 = New-Object Windows.Forms.MenuItem
  $mnuOpaF = New-Object Windows.Forms.MenuItem
  $mnuTgls = New-Object Windows.Forms.MenuItem
  $mnuWrap = New-Object Windows.Forms.MenuItem
  $mnuToS1 = New-Object Windows.Forms.MenuItem
  $mnuToS2 = New-Object Windows.Forms.MenuItem
  $mnuMake = New-Object Windows.Forms.MenuItem
  $mnuBAsm = New-Object Windows.Forms.MenuItem
  $mnuBnRA = New-Object Windows.Forms.MenuItem
  $mnuHelp = New-Object Windows.Forms.MenuItem
  $mnuInfo = New-Object Windows.Forms.MenuItem
  $tbTools = New-Object Windows.Forms.ToolBar
  $btnAtom = New-Object Windows.Forms.ToolBarButton
  $btnToS1 = New-Object Windows.Forms.ToolBarButton
  $btnMake = New-Object Windows.Forms.ToolBarButton
  $btnBAsm = New-Object Windows.Forms.ToolBarButton
  $btnBnRA = New-Object Windows.Forms.ToolBarButton
  $btnExit = New-Object Windows.Forms.ToolBarButton
  $scSplt1 = New-Object Windows.Forms.SplitContainer
  $scSplt2 = New-Object Windows.Forms.SplitContainer
  $lstView = New-Object Windows.Forms.ListView
  $chPoint = New-Object Windows.Forms.ColumnHeader
  $chError = New-Object Windows.Forms.ColumnHeader
  $chCause = New-Object Windows.Forms.ColumnHeader
  $txtEdit = New-Object Windows.Forms.RichTextBox
  $gboMake = New-Object Windows.Forms.GroupBox
  $lblLab1 = New-Object Windows.Forms.Label
  $cboPlat = New-Object Windows.Forms.ComboBox
  $chkExec = New-Object Windows.Forms.CheckBox
  $chkWApp = New-Object Windows.Forms.CheckBox
  $chkIDbg = New-Object Windows.Forms.CheckBox
  $chkIMem = New-Object Windows.Forms.CheckBox
  $lblLab2 = New-Object Windows.Forms.Label
  $txtIOut = New-Object Windows.Forms.TextBox
  $lblLab3 = New-Object Windows.Forms.Label
  $lboRefs = New-Object Windows.Forms.ListBox
  $sbPanel = New-Object Windows.Forms.StatusBar
  $sbPnl_1 = New-Object Windows.Forms.StatusBarPanel
  $sbPnl_2 = New-Object Windows.Forms.StatusBarPanel
  $imgList = New-Object Windows.Forms.ImageList
  $mnuRefs = New-Object Windows.Forms.ContextMenu
  $mnuIMov = New-Object Windows.Forms.MenuItem
  $mnuICnM = New-Object Windows.Forms.MenuItem
  $mnuIBuf = New-Object Windows.Forms.MenuItem
  $mnuIIns = New-Object Windows.Forms.MenuItem
  #
  #mnuMain
  #
  $mnuMain.MenuItems.AddRange(@($mnuFile, $mnuEdit, $mnuView, $mnuMake, $mnuHelp))
  #
  #mnuFile
  #
  $mnuFile.MenuItems.AddRange(@($mnuAtom, $mnuOpen, $mnuEmp1, $mnuExit))
  $mnuFile.Text = "&File"
  #
  #mnuAtom
  #
  $mnuAtom.Shortcut = "F3"
  $mnuAtom.Text = "Nu&Clear..."
  $mnuAtom.Add_Click({Invoke-Atom})
  #
  #mnuOpen
  #
  $mnuOpen.Shortcut = "CtrlO"
  $mnuOpen.Text = "&Open"
  $mnuOpen.Add_Click($mnuOpen_Click)
  #
  #mnuEmp1
  #
  $mnuEmp1.Text = "-"
  #
  #mnuExit
  #
  $mnuExit.Shortcut = "CtrlX"
  $mnuExit.Text = "E&xit"
  $mnuExit.Add_Click({$frmMain.Close()})
  #
  #mnuEdit
  #
  $mnuEdit.menuItems.AddRange(@($mnuUndo, $mnuEmp2, $mnuCopy, $mnuPast, $mnuICut, `
                                                               $mnuEmp3, $mnuSAll))
  $mnuEdit.Text = "&Edit"
  #
  #mnuUndo
  #
  $mnuUndo.Shortcut = "CtrlZ"
  $mnuUndo.Text = "&Undo"
  $mnuUndo.Add_Click({$txtEdit.Undo()})
  #
  #mnuEmp2
  #
  $mnuEmp2.Text = "-"
  #
  #mnuCopy
  #
  $mnuCopy.Shortcut = "CtrlC"
  $mnuCopy.Text = "&Copy"
  $mnuCopy.Add_Click({if ($txtEdit.SelectionLength -ge 0) {$txtEdit.Copy()}})
  #
  #mnuPast
  #
  $mnuPast.Shortcut = "CtrlV"
  $mnuPast.Text = "&Paste"
  $mnuPast.Add_Click({$txtEdit.Paste()})
  #
  #mnuICut
  #
  $mnuICut.Shortcut = "Del"
  $mnuICut.Text = "Cut &Item"
  $mnuICut.Add_Click({if ($txtEdit.SelectionLength -ge 0) {$txtEdit.Cut()}})
  #
  #mnuEmp3
  #
  $mnuEmp3.Text = "-"
  #
  #mnuSAll
  #
  $mnuSAll.Shortcut = "CtrlA"
  $mnuSAll.Text = "Select &All"
  $mnuSAll.Add_Click({$txtEdit.SelectAll()})
  #
  #mnuView
  #
  $mnuView.MenuItems.AddRange(@($mnuFont, $mnuEmp4, $mnuOpac, $mnuTgls))
  $mnuView.Text = "&View"
  #
  #mnuFont
  #
  $mnuFont.Text = "&Font..."
  $mnuFont.Add_Click($mnuFont_Click)
  #
  #mnuEmp4
  #
  $mnuEmp4.Text = "-"
  #
  #mnuOpac
  #
  $mnuOpac.MenuItems.AddRange(@($mnuOp50, $mnuOp60, $mnuOp70, $mnuOp80, $mnuOp90, $mnuOpaF))
  $mnuOpac.Text = "&Opacity"
  #
  #mnuOp50
  #
  $mnuOp50.Text = "50%"
  $mnuOp50.Add_Click({Set-Opacity $mnuOp50; $cur = $mnuOp50})
  #
  #mnuOp60
  #
  $mnuOp60.Text = "60%"
  $mnuOp60.Add_Click({Set-Opacity $mnuOp60; $cur = $mnuOp60})
  #
  #mnuOp70
  #
  $mnuOp70.Text = "70%"
  $mnuOp70.Add_Click({Set-Opacity $mnuOp70; $cur = $mnuOp70})
  #
  #mnuOp80
  #
  $mnuOp80.Text = "80%"
  $mnuOp80.Add_Click({Set-Opacity $mnuOp80; $cur = $mnuOp80})
  #
  #mnuOp90
  #
  $mnuOp90.Text = "90%"
  $mnuOp90.Add_Click({Set-Opacity $mnuOp90; $cur = $mnuOp90})
  #
  #mnuOpaF
  #
  $cur = $mnuOpaF #checked item by default
  $mnuOpaF.Checked = $true
  $mnuOpaF.Text = "Opaque"
  $mnuOpaF.Add_Click($mnuOpaF_Click)
  #
  #mnuTgls
  #
  $mnuTgls.MenuItems.AddRange(@($mnuWrap, $mnuToS1, $mnuToS2))
  $mnuTgls.Text = "&Toggles"
  #
  #mnuWrap
  #
  $mnuWrap.Checked = $true
  $mnuWrap.Shortcut = "CtrlW"
  $mnuWrap.Text = "&Wrap Mode"
  $mnuWrap.Add_Click($mnuWrap_Click)
  #
  #mnuToS1
  #
  $mnuToS1.Checked = $true
  $mnuToS1.Text = "Building &Progress"
  $mnuToS1.Add_Click({Show-Panel $mnuToS1 $scSplt1})
  #
  #mnuToS2
  #
  $mnuToS2.Checked = $true
  $mnuToS2.Shortcut = "F12"
  $mnuToS2.Text = "Building P&roperties"
  $mnuToS2.Add_Click({Show-Panel $mnuToS2 $scSplt2})
  #
  #mnuMake
  #
  $mnuMake.MenuItems.AddRange(@($mnuBAsm, $mnuBnRA))
  $mnuMake.Text = "&Build"
  #
  #mnuBAsm
  #
  $mnuBAsm.Shortcut = "F5"
  $mnuBAsm.Text = "&Compile"
  $mnuBAsm.Add_Click({Invoke-Builder})
  #
  #mnuBnRA
  #
  $mnuBnRA.Shortcut = "F9"
  $mnuBnRA.Text = "Compile And &Run"
  $mnuBnRA.Add_Click({Start-AfterBuilding})
  #
  #mnuHelp
  #
  $mnuHelp.MenuItems.AddRange(@($mnuInfo))
  $mnuHelp.Text = "&Help"
  #
  #mnuInfo
  #
  $mnuInfo.Text = "About..."
  $mnuInfo.Add_Click({frmInfo_Show})
  #
  #tbTools
  #
  $tbTools.Buttons.AddRange(@($btnAtom, $btnToS1, $btnMake, $btnBAsm, $btnBnRA, $btnExit))
  $tbTools.ImageList = $imgList
  $tbTools.Add_ButtonClick($tbTools_ButtonClick)
  #
  #btnAtom
  #
  $btnAtom.ImageIndex = 0
  $btnAtom.Tag = "Atom"
  $btnAtom.ToolTipText = "NuClear (F3)"
  #
  #btnToS1
  #
  $btnToS1.ImageIndex = 1
  $btnToS1.Tag = "Progress"
  $btnToS1.ToolTipText = "Building Progress Panel"
  #
  #btnMake
  #
  $btnMake.ImageIndex = 2
  $btnMake.Tag = "Params"
  $btnMake.ToolTipText = "Building Properties (F12)"
  #
  #btnBAsm
  #
  $btnBAsm.ImageIndex = 3
  $btnBAsm.Tag = "Build"
  $btnBAsm.ToolTipText = "Compile (F5)"
  #
  #btnBnRA
  #
  $btnBnRA.ImageIndex = 4
  $btnBnRA.Tag = "BuildEx"
  $btnBnRA.ToolTipText = "Compile And Run (F9)"
  #
  #btnExit
  #
  $btnExit.ImageIndex = 5
  $btnExit.Tag = "Exit"
  $btnExit.ToolTipText = "Exit (Ctrl+X)"
  #
  #scSplt1
  #
  $scSplt1.Anchor = "Left, Top, Right, Bottom"
  $scSplt1.Location = New-Object Drawing.Point(0, 28)
  $scSplt1.Orientation = "Horizontal"
  $scSplt1.Panel1.Controls.Add($scSplt2)
  $scSplt1.Panel2.Controls.Add($lstView)
  $scSplt1.Size = New-Object Drawing.Size(790, 500)
  $scSplt1.SplitterDistance = 410
  $scSplt1.SplitterWidth = 1
  #
  #scSplt2
  #
  $scSplt2.Dock = "Fill"
  $scSplt2.Panel1.Controls.Add($txtEdit)
  $scSplt2.Panel2.Controls.Add($gboMake)
  $scSplt2.SplitterDistance = 510
  $scSplt2.SplitterWidth = 1
  #
  #lstView
  #
  $lstView.Columns.AddRange(@($chPoint, $chError, $chCause))
  $lstView.Dock = "Fill"
  $lstView.FullRowSelect = $true
  $lstView.GridLines = $true
  $lstView.MultiSelect = $false
  $lstView.ShowItemToolTips = $true
  $lstView.SmallImageList = $imgList
  $lstView.View = "Details"
  #
  #chPoint
  #
  $chPoint.Text = "Line"
  $chPoint.Width = 50
  #
  #chError
  #
  $chError.Text = "Error"
  $chError.TextAlign = "Right"
  $chError.Width = 65
  #
  #chCause
  #
  $chCause.Text = "Description"
  $chCause.Width = 650
  #
  #txtEdit
  #
  $txtEdit.AcceptsTab = $true
  $txtEdit.Dock = "Fill"
  $txtEdit.Font = New-Object Drawing.Font("Courier New", 10)
  $txtEdit.ScrollBars = "Both"
  $txtEdit.Add_Click({Write-CursorPoint})
  $txtEdit.Add_KeyUp({Write-CursorPoint})
  $txtEdit.Add_TextChanged({Write-CursorPoint})
  #
  #gboMake
  #
  $gboMake.Controls.AddRange(@($lblLab1, $cboPlat, $chkExec, $chkWApp, $chkIDbg, `
    $chkIMem, $lblLab2, $txtIOut, $lblLab3, $lboRefs))
  $gboMake.Dock = "Fill"
  $gboMake.Text = "Building Parameters"
  #
  #lblLab1
  #
  $lblLab1.Location = New-Object Drawing.Point(21, 33)
  $lblLab1.Text = "Platform:"
  $lblLab1.Width = 50
  #
  #cboPlat
  #
  $cboPlat.Anchor = "Left, Top, Right"
  $cboPlat.Items.AddRange(@(".NET Framework 2.0", ".NET Framework 3.5"))
  $cboPlat.Location = New-Object Drawing.Point(71, 30)
  $cboPlat.SelectedItem = ".NET Framework 2.0"
  $cboPlat.Width = 180
  $cboPlat.Add_SelectedIndexChanged($cboPlat_SelectedIndexChanged)
  #
  #chkExec
  #
  $chkExec.Checked = $true
  $chkExec.Location = New-Object Drawing.Point(23, 63)
  $chkExec.Text = "Create Executable"
  $chkExec.Width = 120
  $chkExec.Add_Click($chkExec_Click)
  #
  #chkWApp
  #
  $chkWApp.Location = New-Object Drawing.Point(43, 83)
  $chkWApp.Text = "Windows Application"
  $chkWApp.Width = 130
  $chkWApp.Add_Click($chkWApp_Click)
  #
  #chkIDbg
  #
  $chkIDbg.Checked = $true
  $chkIDbg.Location = New-Object Drawing.Point(23, 103)
  $chkIDbg.Text = "Include Debug Information"
  $chkIDbg.Width = 157
  #
  #chkIMem
  #
  $chkIMem.Enabled = $false
  $chkIMem.Location = New-Object Drawing.Point(23, 123)
  $chkIMem.Text = "Building In Memory"
  $chkIMem.Width = 130
  #
  #lblLab2
  #
  $lblLab2.Location = New-Object Drawing.Point(23, 163)
  $lblLab2.Text = "Output:"
  $lblLab2.Width = 45
  #
  #txtIOut
  #
  $txtIOut.Anchor = "Left, Top, Right"
  $txtIOut.Location = New-Object Drawing.Point(71, 160)
  $txtIOut.Width = 180
  #
  #lblLab3
  #
  $lblLab3.Location = New-Object Drawing.Point(23, 203)
  $lblLab3.Size = New-Object Drawing.Size(70, 17)
  $lblLab3.Text = "References:"
  #
  #lboRefs
  #
  $lboRefs.Anchor = "Left, Top, Right, Bottom"
  $lboRefs.ContextMenu = $mnuRefs
  $lboRefs.Location = New-Object Drawing.Point(23, 223)
  $lboRefs.SelectionMode = "One"
  $lboRefs.Size = New-Object Drawing.Size(229, 157)
  #
  #sbPanle
  #
  $sbPanel.Panels.AddRange(@($sbPnl_1, $sbPnl_2))
  $sbPanel.ShowPanels = $true
  $sbPanel.SizingGrip = $false
  #
  #sbPnl_1
  #
  $sbPnl_1.AutoSize = "Spring"
  #
  #sbPnl_2
  #
  $sbPnl_2.Alignment = "Center"
  $sbPnl_2.AutoSize = "Contents"
  #
  #imgList
  #
  $i_1, $i_2, $i_3, $i_4, $i_5, $i_6, $i_7, $i_8 | % { $imgList.Images.Add((Get-Image $_)) }
  #
  #mnuRefs
  #
  $mnuRefs.MenuItems.AddRange(@($mnuIMov, $mnuICnM, $mnuIBuf, $mnuIIns))
  #
  #mnuIMov
  #
  $mnuIMov.Shortcut = "Del"
  $mnuIMov.Text = "Remove Item"
  $mnuIMov.Add_Click({$lboRefs.Items.Remove($lboRefs.SelectedItem)})
  #
  #mnuICnM
  #
  $mnuICnM.Shortcut = "CtrlM"
  $mnuICnM.Text = "Copy And Remove"
  $mnuICnM.Add_Click($mnuICnM_Click)
  #
  #mnuIBuf
  #
  $mnuIBuf.Text = "Insert Copied..."
  $mnuIBuf.Add_Click({if ($script:buff -ne $null) {$lboRefs.Items.Add($script:buff)}})
  #
  #mnuIIns
  #
  $mnuIIns.Shortcut = "CtrlR"
  $mnuIIns.Text = "Add Reference"
  $mnuIIns.Add_Click($mnuIIns_Click)
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(790, 550)
  $frmMain.Controls.AddRange(@($tbTools, $scSplt1, $sbPanel))
  $frmMain.FormBorderStyle = "FixedSingle"
  $frmMain.Icon = $ico
  $frmMain.Menu = $mnuMain
  $frmMain.StartPosition = "CenterScreen"
  $frmMain.Text = "Snippet Compiler"
  $frmMain.Add_Load($frmMain_Load)

  [void]$frmMain.ShowDialog()
}

##################################################################################################

function frmInfo_Show {
  $frmInfo = New-Object Windows.Forms.Form
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
  $lblName.Font = New-Object Drawing.Font("Microsoft Sans Serif", 8, [Drawing.FontStyle]::Bold)
  $lblName.Location = New-Object Drawing.Point(53, 19)
  $lblName.Size = New-Object Drawing.Size(360, 18)
  $lblName.Text = "Snippet Compiler v2.53"
  #
  #lblCopy
  #
  $lblCopy.Location = New-Object Drawing.Point(67, 37)
  $lblCopy.Size = New-Object Drawing.Size(360, 23)
  $lblCopy.Text = "(C) 2012-2013 greg zakharov gregzakh@gmail.com"
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
  $frmInfo.ShowInTaskBar = $false
  $frmInfo.StartPosition = "CenterScreen"
  $frmInfo.Text = "About..."
  $frmInfo.Add_Load({$pbImage.Image = $ico.ToBitmap()})

  [void]$frmInfo.ShowDialog()
}

##################################################################################################

function Invoke-Atom {
  if ($txtEdit.Text -ne "") {
    $res = [Windows.Forms.MessageBox]::Show("Do you want to save data before?", `
                 $frmMain.Text, [Windows.Forms.MessageBoxButtons]::YesNoCancel, `
                                        [Windows.Forms.MessageBoxIcon]::Question)

    switch ($res) {
      'Yes'    {
        (New-Object Windows.Forms.SaveFileDialog) | % {
          $_.FileName = "source"
          $_.Filter = "C# (*.cs)|*.cs"
          $_.InitialDirectory = $def

          if ($_.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
            Out-File $_.FileName -enc UTF8 -input $txtEdit.Text
          }
        }
        break
      }
      'No'     { $txtEdit.Clear(); break }
      'Cancel' { return }
    }
  }#if
}

function Set-Opacity($obj) {
  $cur.Checked = $false
  $frmMain.Opacity = [float]('.' + $($obj.Text)[0])
  $obj.Checked = $true
}

function Show-Panel($obj1, $obj2) {
  switch ($obj1.Checked) {
    $true  {$obj1.Checked = $false; $obj2.Panel2Collapsed = $true; break }
    $false {$obj1.Checked = $true; $obj2.Panel2Collapsed = $false; break }
  }
}

function Get-CursorPoint {
  $z = $txtEdit.SelectionStart
  $y = $txtEdit.GetLineFromCharIndex($z) + 1
  $x = $z - $txtEdit.GetFirstCharIndexOfCurrentLine()

  return (New-Object Drawing.Point($x, $y))
}

function Write-CursorPoint {
  $sbPnl_2.Text = 'Str: ' + (Get-CursorPoint).Y.ToString() + ', Col: ' + `
                                            (Get-CursorPoint).X.ToString()
}

function Invoke-Builder {
  $lstView.Items.Clear()

  if ($txtEdit.Text -ne "") {
    switch ($cboPlat.SelectedIndex) {
      "0" { $cscp = New-Object Microsoft.CSharp.CSharpCodeProvider; break }
      "1" { $cscp = New-Object Microsoft.CSharp.CSharpCodeProvider($dict); break}
    }

    $cdcp.GenerateExecutable = $chkExec.Checked

    if ($chkWApp.Checked) { $cdcp.CompilerOptions = "/t:winexe" }

    $cdcp.IncludeDebugInformation = $chkIDbg.Checked
    $cdcp.GenerateInMemory = $chkIMem.Checked

    if ($lboRefs.Items.Count -ne 0) {
      for ($i = 0; $i -lt $lboRefs.Items.Count; $i++) {
        $cdcp.ReferencedAssemblies.Add($lboRefs.Items[$i].ToString())
      }
    }

    $cdcp.WarningLevel = 3
    $cdcp.OutputAssembly = $txtIOut.Text

    $script:make = $cscp.CompileAssemblyFromSource($cdcp, $txtEdit.Text)
    $make.Errors | % {
      if ($_.Line -ne 0 -and $_.Column -ne 0) {
        $err = $_.Line.ToString() + ', ' + ($_.Column - 1).ToString()
      }
      elseif ($_.Line -ne 0 -and $_.Column -eq 0) {
        $err = $_.Line.ToString() + ', 0'
      }
      elseif ($_.Line -eq 0 -and $_.Column -eq 0) {
        $err = '*'
      }

      if (!($_.IsWarning)) {
        $lstView.ForeColor = [Drawing.Color]::Crimson
        $itm = $lstView.Items.Add($err, 6)
      }
      else {
        $lstView.ForeColor = [Drawing.Color]::Gray
        $itm = $lstView.Items.Add($err, 7)
      }

      $itm.SubItems.Add($_.ErrorNumber)
      $itm.SubItems.Add($_.ErrorText)
    }
  }#if
}

function Start-AfterBuilding {
  Invoke-Builder
  if ($script:make.Errors.Count -eq 0) { Invoke-Item $txtIOut.Text }
}

function Get-Image($img) {
  [Drawing.Image]::FromStream((New-Object IO.MemoryStream(($$ = `
              [Convert]::FromBase64String($img)), 0, $$.Length)))
}

##################################################################################################

#
#do not modify or remove this because these are images for toolbar and lower panel
#
$i_1 = "iVBORw0KGgoAAAANSUhEUgAAAA8AAAARCAIAAACNaGH2AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAA" + `
       "AAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAVFJREFUOE91kTGOgzAQRc2ZOA" + `
       "s9lU+Uxj1lak7hMtJKVCjalSIZkpiEVbSN980Y2GijjEaDgTff3+PiNs/GmJQKKk+txuhboR9TsX7kCd22rXP" + `
       "eeU/d7/eydr5pGuput6NO8yx5n810/4Z7vMT1kUjrCJod9G2h3XvaOp8ScqW1St8iTt5qW1dVVV3XpXXxHoVm" + `
       "r3+0ejCDhveiTYPQcYqcbKN/wof+ddCkXyLhJE5XodFGjAaffIaeE21aVjqODCvTWYzd+75nXcqroATu4zSaG" + `
       "Ee0IWjw3mbHzEE75UtusJwS+hIHxgkkB1KIPBwOyHddt/aIk8s1LDQc9KtpvWIJJij0+XzievOkqHi11ujdO7" + `
       "Q336J9PgnNfW2j5ffz4NYJim+hx/EL7U0Dx8veG7hOcBw+heaU2GIvar7kvNYqiTATFDqE418Ox6A55AySz8A" + `
       "v1EEhBG84RKcAAAAASUVORK5CYII="

$i_2 = "iVBORw0KGgoAAAANSUhEUgAAABIAAAARCAIAAABfOGuuAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAA" + `
       "AAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAOVJREFUOE+VkUEOgyAQRfFMnM" + `
       "NrzJ3Yu3TtKTiEaVOTFgICXXQ3nQG1xjapkOEzII8vQ5OeSQiB1IVoysBZGZY5Yp4vi7QNBWFKoVJ6U8g5Kaw" + `
       "qQUuFrMCaUlwxjeoQfBbBHFtCZxEWV0wDMd8mbMj71iiGGYvRE/A63SRAiI6xYRiIwnNNyoxRL27nKPpPCCFj" + `
       "1W6MzabOTcIcDGN93+dX+h9aa7obY94/6iopwfs7Y13XVZRkwdxUdzcA527Cu6nWjTFrr3VuEqy9MEZuVB96R" + `
       "9ZfSdu2n3XImDHjFtaM+9h/OuRvranSBDuoeeYAAAAASUVORK5CYII="

$i_3 = "iVBORw0KGgoAAAANSUhEUgAAABIAAAAQCAIAAACUZLgLAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAA" + `
       "AAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAWJJREFUOE+FkTFywjAQRcUROI" + `
       "sqWnpKeirVHIFD0OwdqDnFnsANZiZFEguwncad8tYCm2Bmovksa3nffq08a38aN13psTXLyeM5/7MJ9kdtoyK" + `
       "qBFbY7/fE3W4nIRyPR1EJGsxpiqUk2+02pWDSe1QNEjwtIA1r2muvS1ZZljQGoGJgLFGP2PTiKTPMOgiFmg9H" + `
       "UWYWi0UPBFWv4pO4EaubyCyiSTUxTeL0wXOkzWaD53K5BOjlcPJIPIjjhw8M09MYhi5E8tVqxcG8d/P5nLher" + `
       "/vXhri6/sKk67oYIzdBJKcNRZgAYEtBXX8iEh8MGTGqn9fhcOBURVHQCNuMAWS52816vDA81l0C0GQz40zZs0" + `
       "bMvqYoQE6Yl0gO7EN4xa7Xj6lbtjI3bjglDkmZ6XKXG7DBLZsMhpBvsBjPb93G2Xq3SzyjGEtTdXZg3DsvmJv" + `
       "4nOTHvF6xqjr9r+9TlfUo/gXNq15sSG6qYQAAAABJRU5ErkJggg=="

$i_4 = "iVBORw0KGgoAAAANSUhEUgAAABQAAAARCAIAAABSJhvpAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAA" + `
       "AAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAARRJREFUOE9tklFuxCAMROH+J9" + `
       "jTNU1VabUQAmT/qc3AwNJYoyQEPzwYbH5fthRTo1iLN4a26LD0oYyRhFkNga8rQ/JdlR8PUzSMfEA1M6kkrUt" + `
       "+yaDRzKuw8sDmGJWuPGBWa1uoldXmPwvNpsL5zDmIWA01p2ezQF8pB2jAUmR2C8NYAlMIkgqndMQURFgY+8ST" + `
       "/LLtqMghYINnz51p3eIW2PkBx+hifLFb7DDOic7nY0vpJRLKANavGkhiKrq92B7weT6p5WB6WWXZsI98Dmbny" + `
       "zktV20UC+H3rGLP6B+GedXYf0EgQ1j4eW+8WMuGSSrs/c/h90W3Bb3fq7679ntY1loKyp8b2LltkXfbrGn2y7" + `
       "lZ2x9XMW8UGH69+AAAAABJRU5ErkJggg=="

$i_5 = "iVBORw0KGgoAAAANSUhEUgAAABIAAAAQCAIAAACUZLgLAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAA" + `
       "AAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAhNJREFUOE9jfPPyBgMZAKgNju" + `
       "o2nlWtXqVVtQpOAhnIKGDqbohiBmQ9fXuv77rzbsOdtxC08dY7NLTu0tvgaXtQtOk3rQcq7Tv5BEheePFx4rm" + `
       "X7SefQ1DrcRC7+9TLxVdfuEzdiaIN6IAZpx/V7r0F1Pbr77/7H382HH9eeugpEBXvA6GmA89699/OX3ISRVve" + `
       "irNAPambrhXvubPzwXugznOvvmYffJq0/SEQxa+/V7ntYeHasyh+q1x3unLzhYTV53wWnw1afSVpx929jz8Bd" + `
       "a66+8Fu8W3TKZd0u85FzbvqO20fijagC4Ha3OccNZ9+zGTOOasll6P2PHjx9fenn39MZ1xTaTqjUnEideYls9" + `
       "aNKNqAoQx0pFbHTo2+Q0BtufsfPv3yC+i92A13gfYA9egWHMxfchFdm23Xlri5B4DarOadAAYX0HnAgHFdegP" + `
       "oPL3mM5oVx8zKjhStuARUg2Jb1Kx9QTP3WE/bBwx6oMMaD98LX3sdEmnAuAIit8ZjQOd0br+I0Na27ULB4iPu" + `
       "E7YA42T5hYdBi0+Y9O/3n3fmwL13Jx992nH9HRAFdZ0On30YnjZAqQRodeXyg5b1yzTKFwERMHEBkXbtLuPmg" + `
       "0BkUHkE6DFgeAA9gqINmF6m7blQtfJQ/sL9+YsPAW0GxikYXYSg0mVXJ+6+DQw2FG1ADlAnWqpF40KSIro2ZC" + `
       "Fi2ACR3EDpQ7cspgAAAABJRU5ErkJggg=="

$i_6 = "iVBORw0KGgoAAAANSUhEUgAAAA8AAAANCAIAAAD5fKMWAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAA" + `
       "AAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAJxJREFUKFONjEEOwyAMBMn/P5" + `
       "lD1FSCENt5QLpgcA1tpaI52LtjFrk42LvvMi59r9uwwn4jJOAqwAS2llAoMCegHUsq9LWFVVAG22odADm12hS" + `
       "JGyb1s8ioICgcBxudP8A620RPz/T91IZPG4m/8UI4z92AVOcH8AeaoPppfzvYQ86bgs/ysQ3U0ED1l91+hJ3i" + `
       "mlLjiCsoidJzG15Z2J4gUYDWoQAAAABJRU5ErkJggg=="

$i_7 = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAA" + `
       "AAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAsZJREFUOE9FkmtIk1EYx9/nvH" + `
       "u3V+dUyltIIaI5DAsiyy5SlphmCprpirnp8MWaoEikXwzayrQgzTLtQ0hN0UIssyQv1AcnQnMaXlIzTDOsvG7" + `
       "OnG7qTmdq+vBwLpzf/znP4fwBY0z9D6O+k6qpdlha5lOwsri4zDI2eSqz/4DQyWmLoYiAhNlg+JsQjzkOFxXh" + `
       "ykpcUYELCnBGBo6Onj1xfH5iYgOzV9+gLafDcGoqVqlwYSHOzcUKBU5JsWd8PA4NnQvY211fty2Yi47CERE2i" + `
       "eRDerotONjm7W1xdV11d1/192+NicFBQSaxWO/jM/Fz3H7DtE5nDgzEISHNKtXIzExTVtYUwC+A3wBPpFL96K" + `
       "g2O9vg5TXg6VkadtIuGEpKMPj62vz8Rjhu1mIxLi015+aOATy7cvWP0UiIaaXyh0jU6eKicXXt7+ulevcFjnl" + `
       "4kBqTLNsnkxms1sWVlX6t1mQ2E3qc477weH1CYZujY4ODw7VMJdW+c0ePs/N3F5dhgaAfoFuWvGyzEXQN428K" + `
       "hQ5AzzA6gaCVz28QCKRxsVSrl6eWZT+zbA+f3wVQl5NjXSMwJqI2tbodoJ2mP/J4r2i6imEuno+img4famSYN" + `
       "ob5hFCJXD41P0/oSY1mBeMFq/VldnYLQANCGoTu03RSQhzVVVJcw+O9BXisVE6uv7KP494BdHCcaXXVZLHU5+" + `
       "VVkVOaTqbp/PyblMlorBYKNQCNEgmp2p2W9hrgDUJkbJHLib41MfEBwD2EgtzchgYH7D/dUV5WjlAZQK1Y/By" + `
       "gmiRClQBPAaoCAu4C5CMUSdPy5Eub1iDTe7W6mHQJUAJQShoAeAhAtvkAKoBYhI4dPTK/3vCm+ciq/lHJDZHo" + `
       "DkK3AW6tcyQzETrIspFnw41Gw7aXtpw4/HXwuuyyNFB8YZfXOU+PkD27w8+cqq19sbBg2mL+AY/qjcgixtNMA" + `
       "AAAAElFTkSuQmCC"

$i_8 = "iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAIAAAC0tAIdAAAABGdBTUEAALGPC/xhBQAAAglJREFUKFN1jktoE" + `
       "1EUhufMTCbJNNNFS01xZ9GFCCIYhBYUF1XR7nygSxvRVSS6kbQoEoklYggUiuJj300NkRpsXdqNZhHRpp1ETW" + `
       "LSdJJ08piZmFGbx3EmDdoUvfxc/vvf/3wcArtPsXir2bBUq+bZ2Vc7vrQnsT1S1ZKYB0Rbq8F5vSM8n9wx0NU" + `
       "uCK6axCCy2ByURMbhmPlvW1XLxQy5keu96aAWFqxYZ+65j6XT69sH/rILmQlVNLjdrBn2HRiyYbO/+M3k8wX+" + `
       "0VZrlQ2exp/c00cMRx4ZGz6E2NeSmTuu0UpF+TPQYeeTt6spAypsOgZDg+efePejQuMPq7DM+v3BrrZak3IRQ" + `
       "73QgwKJMowcvLwU6kcBUB1orFOuGyclqYPX2YWEW4pSKFowDViGC2eGy3FK9zlTq9SXCfdMT7/cwhP6xmFjY4" + `
       "3DFI0JwAyEnlkxC7r/Cvh9dzNJTzpPyW08kefvKhEasxzGAD+DEqPck8Z3QbNejQOmTCjuyi6x/jaeyL811WM" + `
       "s8hSuAPLwYIKxGPeeOHwa10BPooD5gUaUctrHZFkhsm/gV4Ta/EBqqn8kl+eNo7aj4cDVehQ64Se69p5afL5n" + `
       "5vFr4st878ocuToHW4oHQFiERBBWX3QSLcyESNe142fPTRGKrDiv++zjnivj93XZNeNp35pvJ7o8Fy89LJWk3" + `
       "9PM0i5eafwSAAAAAElFTkSuQmCC"

##################################################################################################

frmMain_Show
