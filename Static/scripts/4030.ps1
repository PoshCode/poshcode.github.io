function frmMain_Show {
  Add-Type -AssemblyName PresentationFramework

  $win = New-Object Windows.Window
  $ink = New-Object Windows.Controls.InkCanvas
  #
  #ink
  #
  $ink.MinWidth = $ink.MinHeight = 450
  #
  #win
  #
  $win.Content = $ink
  $win.SizeToContent = "WidthAndHeight"
  $win.Title = "Paint board"
  $win.WindowStartupLocation = "CenterScreen"

  [void]$win.ShowDialog()
}

frmMain_Show
