$empty = "<NULL>"

$itmType = "Directory", "File"

function LoadTreeView {
  $nodes = [IO.Directory]::GetLogicalDrives()

  $trvRoot.Nodes.Clear()

  foreach ($nod in $nodes) {
    $node = New-Object Windows.Forms.TreeNode
    $node = $trvRoot.Nodes.Add($nod)
    $node.Nodes.Add($empty)
  }
}

function AddFolders {
  $strPath = $_.Node.FullPath
  $_.Node.Nodes.Clear()

  trap {[Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error", `
        [Windows.Forms.MessageBoxButtons]::OK, `
        [Windows.Forms.MessageBoxIcon]::Exclamation); continue }
  foreach ($strDir in [IO.Directory]::GetDirectories($strPath)) {
    $newNode = $_.Node.Nodes.Add([IO.Path]::GetFileName($strDir))
    $newNode.Tag = $itmType[0]
    $newNode.Nodes.Add($empty)
  }
}

function AddFiles {
  $strPath = $_.Node.FullPath

  $ErrorActionPreference = "SilentlyContinue"
  foreach ($strFile in [IO.Directory]::GetFiles($strPath)) {
    $newNode = $_.Node.Nodes.Add([IO.Path]::GetFileName($strFile))
    $newNode.Tag = $itmType[1]
  }
}

function ClearProperties {
  $lblAttributes.Text = [String]::Empty
  $lblCreationTime.Text = [String]::Empty
  $lblLastAccessTime.Text = [String]::Empty
  $lblLastWriteTime.Text = [String]::Empty
  $lblExtension.Text = [String]::Empty
  $lblFullName.Text = [String]::Empty
  $lblName.Text = [String]::Empty
  $lblParent.Text = [String]::Empty
  $lblRoot.Text = [String]::Empty
  $lblLength.Text = [String]::Empty
}

$trvRoot_OnBeforeExpand= {
  AddFolders
  AddFiles
}

$trvRoot_OnAfterSelect= {
  if ($_.Node.Tag -eq $itmType[0]) {
    $lblExtension.Text = [String]::Empty
    $lblLength.Text = [String]::Empty

    $lblLabel5.Enabled = $false
    $lblLabel8.Enabled = $true
    $lblLabel9.Enabled = $true
    $lblLabel10.Enabled = $false

    $di = [IO.DirectoryInfo]($_.Node.FullPath)
    $lblAttributes.Text = $di.Attributes
    $lblCreationTime.Text = $di.CreationTime
    $lblLastAccessTime.Text = $di.LastAccessTime
    $lblLastWriteTime.Text = $di.LastWriteTime
    $lblFullName.Text = $di.FullName
    $lblName.Text = $di.Name
    $lblParent.Text = $di.Parent.Name
    $lblRoot.Text = $di.Root.Name
  }
  elseif ($_.Node.Tag -eq $itmType[1]) {
    $lblParent.Text = [String]::Empty
    $lblRoot.Text = [String]::Empty

    $lblLabel5.Enabled = $true
    $lblLabel8.Enabled = $false
    $lblLabel9.Enabled = $false
    $lblLabel10.Enabled = $true

    $fi = [IO.FileInfo]($_.Node.FullPath)
    $lblAttributes.Text = $fi.Attributes
    $lblCreationTime.Text = $fi.CreationTime
    $lblLastAccessTime.Text = $fi.LastAccessTime
    $lblLastWriteTime.Text = $fi.LastWriteTime
    $lblExtension.Text = $fi.Extension
    $lblFullName.Text = $fi.FullName
    $lblName.Text = $fi.Name
    $lblLength.Text = $fi.Length
  }
  else {
    ClearProperties
  }
}

$mnuRefresh_OnClick= {
  LoadTreeView
  ClearProperties
}

$frmMain_OnLoad= {
  LoadTreeView
}

function ShowMainWindow {
  [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  [void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")

  [Windows.Forms.Application]::EnableVisualStyles()

  $frmMain = New-Object Windows.Forms.Form
  $mnuMain = New-Object Windows.Forms.MainMenu
  $mnuFile = New-Object Windows.Forms.MenuItem
  $mnuRefresh = New-Object Windows.Forms.MenuItem
  $mnuExit = New-Object Windows.Forms.MenuItem
  $mnuHelp = New-Object Windows.Forms.MenuItem
  $mnuAbout = New-Object Windows.Forms.MenuItem
  $trvRoot = New-Object Windows.Forms.TreeView
  $lblLabel1 = New-Object Windows.Forms.Label
  $lblLabel2 = New-Object Windows.Forms.Label
  $lblLabel3 = New-Object Windows.Forms.Label
  $lblLabel4 = New-Object Windows.Forms.Label
  $lblLabel5 = New-Object Windows.Forms.Label
  $lblLabel6 = New-Object Windows.Forms.Label
  $lblLabel7 = New-Object Windows.Forms.Label
  $lblLabel8 = New-Object Windows.Forms.Label
  $lblLabel9 = New-Object Windows.Forms.Label
  $lblLabel10 = New-Object Windows.Forms.Label
  $lblAttributes = New-Object Windows.Forms.Label
  $lblCreationTime = New-Object Windows.Forms.Label
  $lblLastAccessTime = New-Object Windows.Forms.Label
  $lblLastWriteTime = New-Object Windows.Forms.Label
  $lblExtension = New-Object Windows.Forms.Label
  $lblFullName = New-Object Windows.Forms.Label
  $lblName = New-Object Windows.Forms.Label
  $lblParent = New-Object Windows.Forms.Label
  $lblRoot = New-Object Windows.Forms.Label
  $lblLength = New-Object Windows.Forms.Label

  #mnuMain
  $mnuMain.MenuItems.AddRange(@($mnuFile, $mnuHelp))

  #mnuFile
  $mnuFile.MenuItems.AddRange(@($mnuRefresh, $mnuExit))
  $mnuFile.Text = "&File"

  #mnuRefresh
  $mnuRefresh.Shortcut = "F5"
  $mnuRefresh.Text = "&Refresh"
  $mnuRefresh.Add_Click($mnuRefresh_OnClick)

  #mnuExit
  $mnuExit.Shortcut = "CtrlX"
  $mnuExit.Text = "E&xit"
  $mnuExit.Add_Click( { $frmMain.Close() } )

  #mnuHelp
  $mnuHelp.MenuItems.AddRange(@($mnuAbout))
  $mnuHelp.Text = "&Help"

  #mnuAbout
  $mnuAbout.Text = "About"
  $mnuAbout.Add_Click( { ShowAboutWindow } )

  #trvRoot
  $trvRoot.Anchor = "Top, Bottom, Left, Right"
  $trvRoot.Location = New-Object Drawing.Point(8, 8)
  $trvRoot.Size = New-Object Drawing.Size(392, 195)
  $trvRoot.Add_BeforeExpand($trvRoot_OnBeforeExpand)
  $trvRoot.Add_AfterSelect($trvRoot_OnAfterSelect)

  #lblLabel1
  $lblLabel1.Anchor = "Bottom, Left"
  $lblLabel1.Location = New-Object Drawing.Point(8, 210)
  $lblLabel1.Size = New-Object Drawing.Size(104, 23)
  $lblLabel1.Text = "Attributes:"
  $lblLabel1.TextAlign = "MiddleRight"

  #lblLabel2
  $lblLabel2.Anchor = "Bottom, Left"
  $lblLabel2.Location = New-Object Drawing.Point(8, 234)
  $lblLabel2.Size = New-Object Drawing.Size(104, 23)
  $lblLabel2.Text = "Creation Time:"
  $lblLabel2.TextAlign = "MiddleRight"

  #lblLabel3
  $lblLabel3.Anchor = "Bottom, Left"
  $lblLabel3.Location = New-Object Drawing.Point(8, 258)
  $lblLabel3.Size = New-Object Drawing.Size(104, 23)
  $lblLabel3.Text = "Last Access Time:"
  $lblLabel3.TextAlign = "MiddleRight"

  #lblLabel4
  $lblLabel4.Anchor = "Bottom, Left"
  $lblLabel4.Location = New-Object Drawing.Point(8, 282)
  $lblLabel4.Size = New-Object Drawing.Size(104, 23)
  $lblLabel4.Text = "Last Write Time:"
  $lblLabel4.TextAlign = "MiddleRight"

  #lblLabel5
  $lblLabel5.Anchor = "Bottom, Left"
  $lblLabel5.Location = New-Object Drawing.Point(8, 314)
  $lblLabel5.Size = New-Object Drawing.Size(104, 23)
  $lblLabel5.Text = "Extension:"
  $lblLabel5.TextAlign = "MiddleRight"

  #lblLabel6
  $lblLabel6.Anchor = "Bottom, Left"
  $lblLabel6.Location = New-Object Drawing.Point(8, 338)
  $lblLabel6.Size = New-Object Drawing.Size(104, 23)
  $lblLabel6.Text = "Full Name:"
  $lblLabel6.TextAlign = "MiddleRight"

  #lblLabel7
  $lblLabel7.Anchor = "Bottom, Left"
  $lblLabel7.Location = New-Object Drawing.Point(8, 362)
  $lblLabel7.Size = New-Object Drawing.Size(104, 23)
  $lblLabel7.Text = "Name:"
  $lblLabel7.TextAlign = "MiddleRight"

  #lblLabel8
  $lblLabel8.Anchor = "Bottom, Left"
  $lblLabel8.Location = New-Object Drawing.Point(8, 386)
  $lblLabel8.Size = New-Object Drawing.Size(104, 23)
  $lblLabel8.Text = "Parent:"
  $lblLabel8.TextAlign = "MiddleRight"

  #lblLabel9
  $lblLabel9.Anchor = "Bottom, Left"
  $lblLabel9.Location = New-Object Drawing.Point(8, 410)
  $lblLabel9.Size = New-Object Drawing.Size(104, 23)
  $lblLabel9.Text = "Root:"
  $lblLabel9.TextAlign = "MiddleRight"

  #lblLabel10
  $lblLabel10.Anchor = "Bottom, Left"
  $lblLabel10.Location = New-Object Drawing.Point(8, 434)
  $lblLabel10.Size = New-Object Drawing.Size(104, 23)
  $lblLabel10.Text = "Length:"
  $lblLabel10.TextAlign = "MiddleRight"

  #lblAttributes
  $lblAttributes.Anchor = "Bottom, Left, Right"
  $lblAttributes.BorderStyle = "Fixed3D"
  $lblAttributes.Location = New-Object Drawing.Point(120, 211)
  $lblAttributes.Size = New-Object Drawing.Size(280, 20)
  $lblAttributes.TextAlign = "MiddleLeft"

  #lblCreationTime
  $lblCreationTime.Anchor = "Bottom, Left, Right"
  $lblCreationTime.BorderStyle = "Fixed3D"
  $lblCreationTime.Location = New-Object Drawing.Point(120, 235)
  $lblCreationTime.Size = New-Object Drawing.Size(280, 20)
  $lblCreationTime.TextAlign = "MiddleLeft"

  #lblLastAccessTime
  $lblLastAccessTime.Anchor = "Bottom, Left, Right"
  $lblLastAccessTime.BorderStyle = "Fixed3D"
  $lblLastAccessTime.Location = New-Object Drawing.Point(120, 259)
  $lblLastAccessTime.Size = New-Object Drawing.Size(280, 20)
  $lblLastAccessTime.TextAlign = "MiddleLeft"

  #lblLastWriteTime
  $lblLastWriteTime.Anchor = "Bottom, Left, Right"
  $lblLastWriteTime.BorderStyle = "Fixed3D"
  $lblLastWriteTime.Location = New-Object Drawing.Point(120, 283)
  $lblLastWriteTime.Size = New-Object Drawing.Size(280, 20)
  $lblLastWriteTime.TextAlign = "MiddleLeft"

  #lblExtension
  $lblExtension.Anchor = "Bottom, Left, Right"
  $lblExtension.BorderStyle = "Fixed3D"
  $lblExtension.Location = New-Object Drawing.Point(120, 315)
  $lblExtension.Size = New-Object Drawing.Size(280, 20)
  $lblExtension.TextAlign = "MiddleLeft"

  #lblFullName
  $lblFullName.Anchor = "Bottom, Left, Right"
  $lblFullName.BorderStyle = "Fixed3D"
  $lblFullName.Location = New-Object Drawing.Point(120, 339)
  $lblFullName.Size = New-Object Drawing.Size(280, 20)
  $lblFullName.TextAlign = "MiddleLeft"

  #lblName
  $lblName.Anchor = "Bottom, Left, Right"
  $lblName.BorderStyle = "Fixed3D"
  $lblName.Location = New-Object Drawing.Point(120, 363)
  $lblName.Size = New-Object Drawing.Size(280, 20)
  $lblName.TextAlign = "MiddleLeft"

  #lblParent
  $lblParent.Anchor = "Bottom, Left, Right"
  $lblParent.BorderStyle = "Fixed3D"
  $lblParent.Location = New-Object Drawing.Point(120, 387)
  $lblParent.Size = New-Object Drawing.Size(280, 20)
  $lblParent.TextAlign = "MiddleLeft"

  #lblRoot
  $lblRoot.Anchor = "Bottom, Left, Right"
  $lblRoot.BorderStyle = "Fixed3D"
  $lblRoot.Location = New-Object Drawing.Point(120, 411)
  $lblRoot.Size = New-Object Drawing.Size(280, 20)
  $lblRoot.TextAlign = "MiddleLeft"

  #lblLength
  $lblLength.Anchor = "Bottom, Left, Right"
  $lblLength.BorderStyle = "Fixed3D"
  $lblLength.Location = New-Object Drawing.Point(120, 435)
  $lblLength.Size = New-Object Drawing.Size(280, 20)
  $lblLength.TextAlign = "MiddleLeft"

  #frmMain
  $frmMain.ClientSize = New-Object Drawing.Size(408, 463)
  $frmMain.Controls.AddRange(@($trvRoot, $lblLabel1, $lblLabel2, $lblLabel3, $lblLabel4, `
                             $lblLabel5, $lblLabel6, $lblLabel7, $lblLabel8, $lblLabel9, `
                             $lblLabel10, $lblAttributes, $lblCreationTime, $lblLastAccessTime, `
                             $lblLastWriteTime, $lblExtension, $lblFullName, $lblName, `
                             $lblParent, $lblRoot, $lblLength))
  $frmMain.Menu = $mnuMain
  $frmMain.StartPosition = "CenterScreen"
  $frmMain.Text = "File Navigator"
  $frmMain.Add_Load($frmMain_OnLoad)

  [void]$frmMain.ShowDialog()
}

function ShowAboutWindow {
  $frmAbout = New-Object Windows.Forms.Form
  $lblInfo = New-Object Windows.Forms.Label
  $btnExit = New-Object Windows.Forms.Button

  #lblInfo
  $lblInfo.Location = New-Object Drawing.Point(13, 23)
  $lblInfo.Size = New-Object Drawing.Size(270, 50)
  $lblInfo.Text = "(C) 2012 Grigori Zakharov `n
    This is just an example that you can make better."

  #btnExit
  $btnExit.Location = New-Object Drawing.Point(100, 80)
  $btnExit.TabIndex = 0
  $btnExit.Text = "Close"
  $btnExit.Add_Click( { $frmAbout.Close() } )

  #frmAbot
  $frmAbout.ClientSize = New-Object Drawing.Size(280, 117)
  $frmAbout.ControlBox = $false
  $frmAbout.Controls.AddRange(@($lblInfo, $btnExit))
  $frmAbout.FormBorderStyle = "FixedSingle"
  $frmAbout.ShowInTaskbar = $false
  $frmAbout.StartPosition = "CenterScreen"
  $frmAbout.Text = "About..."

  [void]$frmAbout.ShowDialog()
}

ShowMainWindow
