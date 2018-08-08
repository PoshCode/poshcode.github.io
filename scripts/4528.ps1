function Search-WithMode {
  if (-not [String]::IsNullOrEmpty($txtFile.Text)) {
    foreach ($p in ($env:path -split ';')) {
      foreach ($e in ($env:pathext -split ';')) {
        $mat = $p + '\' + $txtFile.Text + $e.ToLower()
        if (Test-Path $mat) {
          if ($rbWhich.Checked) {$lstView.Items.Add($mat)}
          elseif ($rbWhere.Checked) {$lstView.Items.Add((Split-Path $mat))}
        }
      }
    }
  }
}

function frmMain_Show {
  Add-Type -AssemblyName System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()
  
  $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
  
  $frmMain = New-Object Windows.Forms.Form
  $txtFile = New-Object Windows.Forms.TextBox
  $btnFind = New-Object Windows.Forms.Button
  $rbWhich = New-Object Windows.Forms.RadioButton
  $rbWhere = New-Object Windows.Forms.RadioButton
  $lstView = New-Object Windows.Forms.ListView
  $chFound = New-Object Windows.Forms.ColumnHeader
  #
  #txtFile
  #
  $txtFile.Anchor = "Left, Top, Right"
  $txtFile.Location = New-Object Drawing.Point(13, 13)
  $txtFile.Size = New-Object Drawing.Size(400, 27)
  #
  #btnFind
  #
  $btnFind.Anchor = "Top, Right"
  $btnFind.Location = New-Object Drawing.Point(423, 13)
  $btnFind.Size = New-Object Drawing.Size(90, 22)
  $btnFind.Text = "Search"
  $btnFind.Add_Click({Search-WithMode})
  #
  #rbWhich
  #
  $rbWhich.Anchor = "Left, Top"
  $rbWhich.Checked = $true
  $rbWhich.Location = New-Object Drawing.Point(13, 33)
  $rbWhich.Text = "Which mode"
  #
  #rbWhere
  #
  $rbWhere.Anchor = "Left, Top"
  $rbWhere.Location = New-Object Drawing.Point(123, 33)
  $rbWhere.Text = "Where mode"
  #
  #lstView
  #
  $lstView.Anchor = "Left, Bottom, Right, Top"
  $lstView.Columns.AddRange(@($chFound))
  $lstView.FullRowSelect = $true
  $lstView.Location = New-Object Drawing.Point(13, 57)
  $lstView.Size = New-Object Drawing.Size(500, 237)
  $lstView.View = "Details"
  #
  #chFound
  #
  $chFound.Text = "Match(es) history"
  $chFound.Width = 495
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(527, 312)
  $frmMain.Controls.AddRange(@($txtFile, $btnFind, $rbWhich, $rbWhere, $lstView))
  $frmMain.FormBorderStyle = "FixedSingle"
  $frmMain.Icon = $ico
  $frmMain.StartPosition = "CenterScreen"
  $frmMain.Text = "Which"
  
  [void]$frmMain.ShowDialog()
}

frmMain_Show
