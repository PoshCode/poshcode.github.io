#requires -version 2.0
Set-Alias ohv Out-HexView

function Out-HexView {
  <#
    .EXAMPLE
        PS C:\>Out-HexView foo.txt
    .EXAMPLE
        PS C:\>'\Downloads\MyBinary.exe' | Out-HexView -bytes 25
    .NOTES
        This script is somewhat similar to Out-GridView but its end result is a file hexadecimal dump.
        Out-HexView v1.0
        Please donate if you find this script useful (Yandex.Money - 410012070594869)
  #>
  [CmdletBinding(DefaultParameterSetName="FileName", SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory=$true,
               Position=0,
               ValueFromPipeline=$true)]
    [String]$FileName,
    
    [Parameter(Position=1)]
    [Int32]$BytesToProcess = -1
  )
  
  begin {
    function frmMain_Show([Byte[]]$bytes, [String]$file) {
      Add-Type -Assembly System.Design, System.Windows.Forms
      [Windows.Forms.Application]::EnableVisualStyles()
      
      $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
      
      $frmMain = New-Object Windows.Forms.Form
      $tsStrip = New-Object Windows.Forms.ToolStrip
      $tsLabel = New-Object Windows.Forms.ToolStripLabel
      $tsCombo = New-Object Windows.Forms.ToolStripComboBox
      $bvBytes = New-Object ComponentModel.Design.ByteViewer
      $sbStrip = New-Object Windows.Forms.StatusStrip
      $sbLabel = New-Object Windows.Forms.ToolStripStatusLabel
      #
      #common
      #
      $tsStrip.Items.AddRange(@($tsLabel, $tsCombo))
      $tsLabel.Text = "Display Mode:"
      #
      #tsCombo
      #
      [Enum]::GetValues([ComponentModel.Design.DisplayMode]) | % {
        [void]$tsCombo.Items.Add($_)
      }
      $tsCombo.SelectedIndex = 0
      $tsCombo.Add_SelectedIndexChanged({
        if ($bvBytes.GetBytes() -ne $null) {
          $bvBytes.SetDisplayMode([ComponentModel.Design.DisplayMode]$tsCombo.SelectedItem)
        }
      })
      #
      #bvBytes
      #
      $bvBytes.Dock = "Fill"
      $bvBytes.SetBytes($bytes)
      #
      #sbStrip
      #
      $sbStrip.Items.AddRange(@($sbLabel))
      $sbStrip.SizingGrip = $false
      #
      #sbLabel
      #
      $sbLabel.AutoSize = $true
      $sbLabel.ForeColor = [Drawing.Color]::DarkCyan
      $sbLabel.Text = $file
      #
      #frmMain
      #
      $frmMain.ClientSize = New-Object Drawing.Size(630, 437)
      $frmMain.Controls.AddRange(@($bvBytes, $sbStrip, $tsStrip))
      $frmMain.FormBorderStyle = "FixedSingle"
      $frmMain.Icon = $ico
      $frmMain.MaximizeBox = $false
      $frmMain.MinimizeBox = $false
      $frmMain.StartPosition = "CenterScreen"
      $frmMain.Text = $PSCmdlet.CommandRuntime
      
      [void]$frmMain.ShowDialog()
    }
  }
  process {
    if ($PSCmdlet.ShouldProcess($FileName, "Get a hex dump of")) {
      if (Test-Path $FileName) {
        $itm = cvpa $FileName
        frmMain_Show (cat $itm -enc Byte -tot $BytesToProcess) $itm
        
      }
      else {Write-Warning ("file " + $FileName + " does not exist!")}
    }
  }
  end {}
}
