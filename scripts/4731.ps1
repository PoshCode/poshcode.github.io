#requires -version 2.0
#function frmMain_Show {
  [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  [Windows.Forms.Application]::EnableVisualStyles()
  
  $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
  
  $bold = New-Object Drawing.Font("Tahoma", 9, [Drawing.FontStyle]::Bold)
  $norm = New-Object Drawing.Font("Tahoma", 9, [Drawing.FontStyle]::Regular)
  
  $frmMain = New-Object Windows.Forms.Form
  $scSplit = New-Object Windows.Forms.SplitContainer
  $lvNames = New-Object Windows.Forms.ListView
  $rtbInfo = New-Object Windows.Forms.RichTextBox
  $sbStrip = New-Object Windows.Forms.StatusStrip
  $sbLabel = New-Object Windows.Forms.ToolStripStatusLabel
  #
  #common
  #
  $sbStrip.Items.AddRange(@($sbLabel))
  $sbLabel.AutoSize = $true
  #
  #scSplit
  #
  $scSplit.Dock = "Fill"
  $scSplit.Panel1.Controls.Add($lvNames)
  $scSplit.Panel2.Controls.Add($rtbInfo)
  $scSplit.SplitterWidth = 1
  #
  #lvNames
  #
  $lvNames.Dock = "Fill"
  $lvNames.FullRowSelect = $true
  $lvnames.MultiSelect = $false
  $lvNames.Sorting = [Windows.Forms.SortOrder]::Ascending
  $lvNames.TileSize = New-Object Drawing.Size(270, 17)
  $lvNames.View = "Tile"
  $lvNames.Add_Click({
    $rtbInfo.Clear()
    $sbLabel.Text = "Ready"
    
    for ($i = 0; $i -lt $lvNames.Items.Count; $i++) {
      if ($lvNames.Items[$i].Selected) {
        $rtbInfo.SelectionFont = $bold
        $rtbInfo.AppendText("$($lvNames.Items[$i].Text)`n")
        
        $pcc = New-Object Diagnostics.PerformanceCounterCategory($lvNames.Items[$i].Text, ".")
        $rtbInfo.AppendText("$($pcc.CategoryHelp)`n`n$('=' * 55)`n`n")
        
        if ($pcc.GetInstanceNames().Length -ne 0) {
          $rtbInfo.SelectionFont = $bold
          $rtbInfo.AppendText("Instances:`n")
          
          $pcc.GetInstanceNames() | sort | % {
            $rtbInfo.SelectionColor = [Drawing.Color]::Blue
            $rtbInfo.AppendText("`t$_`n")
          }
          $rtbInfo.AppendText("`n$('=' * 55)`n`n")
        }
        
        $rtbInfo.SelectionFont = $bold
        $rtbInfo.AppendText("Counters:`n")
        
        try {
          $pcc.GetCounters() | % {
            $rtbInfo.SelectionColor = [Drawing.Color]::FromArgb(125, 0, 255)
            $rtbInfo.AppendText("$((' ' * 3) + $_.CounterName)`n")
            $rtbInfo.AppendText("$((' ' * 3) + $_.CounterHelp)`n`n")
          }
        }
        catch {
          $pcc.ReadCategory().GetEnumerator() | % {
            $rtbInfo.SelectionColor = [Drawing.Color]::FromArgb(125, 0, 255)
            $rtbInfo.AppendText("$((' ' * 3) + $_.Key)`n")
          }
          $sbLabel.Text = "Can not read description of counters in current context."
        }
      }
    }
  })
  #
  #rtbInfo
  #
  $rtbInfo.Dock = "Fill"
  $rtbInfo.Font = $norm
  $rtbInfo.ReadOnly = $true
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(800, 470)
  $frmMain.Controls.AddRange(@($scSplit, $sbStrip))
  $frmMain.Icon = $ico
  $frmMain.StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
  $frmMain.Text = "Performance Counters"
  $frmMain.Add_Load({
    [Diagnostics.PerformanceCounterCategory]::GetCategories(".") | % {
      $lvNames.Items.Add($_.CategoryName)
    }
    $sbLabel.Text = "Ready"
  })
  
  [void]$frmMain.ShowDialog()
#}
