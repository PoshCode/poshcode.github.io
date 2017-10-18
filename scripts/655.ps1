# defrag_analysis.ps1
#
# Displays Defrag Analysis Info for a remote server.
#
# Author: tojo2000@tojo2000.com

Set-PSDebug -Strict`

trap [Exception] {
  continue
}

function GenerateForm {
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null

$form1 = New-Object System.Windows.Forms.Form
$richTextBox1 = New-Object System.Windows.Forms.RichTextBox
$textBox1 = New-Object System.Windows.Forms.TextBox
$button1 = New-Object System.Windows.Forms.Button

$handler_button1_Click = {
  $richTextBox1.Text = ''
	$volumes = @(gwmi Win32_Volume -ComputerName $textBox1.Text `
	             -Filter 'DriveType = 3')
	
	foreach ($volume in $volumes) {
	  $analysis = $volume.DefragAnalysis().DefragAnalysis
		Write-TextBox "Drive               : $($volume.DriveLetter)"
		Write-TextBox "Volume Name         : $($analysis.VolumeName)"
		Write-TextBox ("Volume Size         : " +
		               "{0:0.00}GB" -f ($analysis.VolumeSize/1GB))
		Write-TextBox "Total Fragmentation : $($analysis.TotalPercentFragmentation)%"
    Write-TextBox ""
		Write-TextBox "Free Space          : $($analysis.FreeSpacePercent)%"
		Write-TextBox ("Free Space Frag.    : " +
		               "$($analysis.FreeSpacePercentFragmentation)%")
    Write-TextBox ""
		Write-TextBox "Files               : $($analysis.TotalFiles)"
		Write-TextBox "Fragmented Files    : $($analysis.TotalFragmentedFiles)"
		Write-TextBox "File Fragmentation  : $($analysis.FilePercentFragmentation)%"
    Write-TextBox ""
		Write-TextBox "Folders             : $($analysis.TotalFolders)"
		Write-TextBox "Fragmented Folders  : $($analysis.FragmentedFolders)"
    Write-TextBox ""
		Write-TextBox "MFT Usage           : $($analysis.MFTPercentInUse)%"
		Write-TextBox "MFT Fragments       : $($analysis.TotalMFTFragments)"
		Write-TextBox "MFT Records         : $($analysis.MFTRecordCount)"
    Write-TextBox ""
		Write-TextBox ("PageFile Size       : " +
		               "{0:0.00}GB" -f ($analysis.PageFileSize/1GB))
		Write-TextBox "PageFile Fragments  : $($analysis.TotalPageFileFragments)"
    Write-TextBox ""
    Write-TextBox "----------------------------"
	}
}

$handler_form1_Load = {
  $textBox1.Select()
}

$form1.Name = 'form1'
$form1.Text = 'Defrag Info 1.0'
$form1.BackColor = [System.Drawing.Color]::FromArgb(255,227,227,227)
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 428
$System_Drawing_Size.Height = 404
$form1.ClientSize = $System_Drawing_Size

$form1.add_Load($handler_form1_Load)

$richTextBox1.Text = ''
$richTextBox1.TabIndex = 2
$richTextBox1.Name = 'richTextBox1'
$richTextBox1.Font = New-Object System.Drawing.Font("Courier New",10,0,3,0)
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 343
$System_Drawing_Size.Height = 315
$richTextBox1.Size = $System_Drawing_Size
$richTextBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 40
$System_Drawing_Point.Y = 61
$richTextBox1.Location = $System_Drawing_Point

$form1.Controls.Add($richTextBox1)

$textBox1.Text = '<Enter Server Name>'
$textBox1.Name = 'textBox1'
$textBox1.TabIndex = 1
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 250
$System_Drawing_Size.Height = 20
$textBox1.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 40
$System_Drawing_Point.Y = 21
$textBox1.Location = $System_Drawing_Point
$textBox1.DataBindings.DefaultDataSourceUpdateMode = 0

$form1.Controls.Add($textBox1)

$button1.UseVisualStyleBackColor = $True
$button1.Text = 'Analyze'
$button1.DataBindings.DefaultDataSourceUpdateMode = 0
$button1.TabIndex = 0
$button1.Name = 'button1'
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 75
$System_Drawing_Size.Height = 23
$button1.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 308
$System_Drawing_Point.Y = 19
$button1.Location = $System_Drawing_Point
$button1.add_Click($handler_button1_Click)

$form1.Controls.Add($button1)

$form1.ShowDialog()| Out-Null

}

function Write-TextBox {
  param([string]$text)
	$richTextBox1.Text += "$text`n"
}

# Launch the form
GenerateForm


