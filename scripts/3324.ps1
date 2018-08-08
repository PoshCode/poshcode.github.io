function Show-Image {
  param([string]$file = $(throw "No file specified."))

  [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  [void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")

  #maybe this idea is not good but it can help display big images
  [Windows.Forms.Screen]::AllScreens | % -p {
    $maxHeight = ($_.Bounds).Height
    $maxWidth = ($_.Bounds).Width
  }

  if (Test-Path $file) {
    #loading image
    $pic = [Drawing.Image]::FromFile((rvpa $file).Path)

    #window size is equal image
    $size = $pic.Size

    #form
    $frmMain = New-Object Windows.Forms.Form
    $picArea = New-Object Windows.Forms.PictureBox

    #picArea
    $picArea.Dock = "Fill"
    $picArea.Image = New-Object Drawing.Bitmap((rvpa $file).Path)
    $picArea.SizeMode = "StretchImage"

    #frmMain
    $frmMain.AutoScroll = $true
    $frmMain.Controls.AddRange(@($picArea))
    $frmMain.FormBorderStyle = "None"
    $frmMain.StartPosition = "CenterScreen"
    $frmMain.Text = $file
    $frmMain.Add_KeyDown( { if ($_.KeyCode -eq "Escape") {$frmMain.Close()} } )

    #checking sizes
    if ($size.Height -ge $maxHeight -and $size.Width -ge $maxWidth) {
      $frmMain.Size = New-Object Drawing.Size($maxWidth, $maxHeight)
    }
    else {
      $frmMain.Size = $size
    }

    [void]$frmMain.ShowDialog()
    #this can escape locking image file with host
    $pic.Dispose()
  }
}
