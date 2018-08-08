#code which need highlight
$code = @'
#just example
Get-Process | % {
  try {
    "{0, 7} {1}" -f $_.Id, $_.MainModule.ModuleName
  }
  catch [System.ComponentModel.Win32Exception] {}
}
'@

function frmMain_Show {
  Add-Type -AssemblyName System.Windows.Forms
  [Windows.Forms.Application]::EnableVisualStyles()

  #keywords
  $type = New-Object "Collections.Generic.Dictionary[String, [Drawing.Color]]"
  $type["Command"]    = [Drawing.Color]::Cyan
  $type["Comment"]    = [Drawing.Color]::Gray
  $type["GroupStart"] = [Drawing.Color]::Orange
  $type["GroupEnd"]   = [Drawing.Color]::Orange
  $type["Keyword"]    = [Drawing.Color]::FromArgb(0, 255, 0)
  $type["Member"]     = [Drawing.Color]::Tomato
  $type["Operator"]   = [Drawing.Color]::Linen
  $type["String"]     = [Drawing.Color]::Yellow
  $type["Type"]       = [Drawing.Color]::Silver
  $type["Variable"]   = [Drawing.Color]::Crimson

  #main form
  $frmMain = New-Object Windows.Forms.Form
  $txtEdit = New-Object Windows.Forms.RichTextBox
  #
  #txtEdit
  #
  $txtEdit.BackColor = [Drawing.Color]::FromArgb(1, 36, 86)
  $txtEdit.Dock = "Fill"
  $txtEdit.Font = New-Object Drawing.Font("Courier New", 10, [Drawing.FontStyle]::Bold)
  $txtEdit.Text = $code
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(490, 190)
  $frmMain.Controls.Add($txtEdit)
  $frmMain.FormBorderStyle = "FixedSingle"
  $frmMain.MaximizeBox = $false
  $frmMain.StartPosition = "CenterScreen"
  $frmMain.Text = "gregzakh@gmail.com"

  #counter
  $i = 0
  #highlight code
  [Management.Automation.PSParser]::Tokenize(
    $txtEdit.Text,
    [ref](New-Object "Collections.ObjectModel.Collection[Management.Automation.PSParseError]")
  ) | % {
    $txtEdit.SelectionStart = $_.Start - $i
    $txtEdit.SelectionLength = $_.Length

    #skip unnecessary types
    if ($_.Type -eq "LineContinuation" -or $_.Type -eq "NewLine") {
      $i++
    }
    else {
      $txtEdit.SelectionColor = $type[$_.Type.ToString()]
    }
  }
  #when done
  $txtEdit.DeselectAll()

  #show form
  [void]$frmMain.ShowDialog()
}

frmMain_Show
