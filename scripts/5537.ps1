﻿#========================================================================
# Code Generated By: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.1.26
# Generated On: 2014-10-24 12:41
# Generated By: Anders Wahlqvist 
# Site: http://dollarunderscore.azurewebsites.net
#========================================================================
#----------------------------------------------
#region Application Functions
#----------------------------------------------

function OnApplicationLoad {
	#Note: This function is not called in Projects
	#Note: This function runs before the form is created
	#Note: To get the script directory in the Packager use: Split-Path $hostinvocation.MyCommand.path
	#Note: To get the console output in the Packager (Windows Mode) use: $ConsoleOutput (Type: System.Collections.ArrayList)
	#Important: Form controls cannot be accessed in this function
	#TODO: Add snapins and custom code to validate the application load
	
	Import-Module ActiveDirectory
	
	return $true #return true for success or false for failure
}

function OnApplicationExit {
	#Note: This function is not called in Projects
	#Note: This function runs after the form is closed
	#TODO: Add custom code to clean up and unload snapins when the application exits
	
	$script:ExitCode = 0 #Set the exit code for the Packager
}

#endregion Application Functions

#----------------------------------------------
# Generated Form Function
#----------------------------------------------
function Call-ExportADGroupMembers_pff {

	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load("mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	[void][reflection.assembly]::Load("System.Xml, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	[void][reflection.assembly]::Load("System.Core, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.ServiceProcess, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$formExportGroupMembers = New-Object 'System.Windows.Forms.Form'
	$buttonExportTreeStructure = New-Object 'System.Windows.Forms.Button'
	$buttonBrowseFolder = New-Object 'System.Windows.Forms.Button'
	$textboxFile = New-Object 'System.Windows.Forms.TextBox'
	$buttonExportMembers = New-Object 'System.Windows.Forms.Button'
	$labelSaveTo = New-Object 'System.Windows.Forms.Label'
	$statusbar1 = New-Object 'System.Windows.Forms.StatusBar'
	$checkboxRecursive = New-Object 'System.Windows.Forms.CheckBox'
	$labelADGroupName = New-Object 'System.Windows.Forms.Label'
	$textbox1 = New-Object 'System.Windows.Forms.TextBox'
	$openfiledialog1 = New-Object 'System.Windows.Forms.OpenFileDialog'
	$folderbrowserdialog1 = New-Object 'System.Windows.Forms.FolderBrowserDialog'
	$savefiledialog1 = New-Object 'System.Windows.Forms.SaveFileDialog'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
	
	
	
	
	
	
	$formExportGroupMembers_Load={
		#TODO: Initialize Form Controls here
		
	}
	
	$buttonBrowse_Click={
	
		if($openfiledialog1.ShowDialog() -eq 'OK')
		{
			$textboxFile.Text = $openfiledialog1.FileName
		}
	}
	
	$buttonExportMembers_Click={
		#TODO: Place custom script here
		
		$GroupMembers = $null
		
		if ($checkboxRecursive.Checked) {
			try {
				$GroupMembers = Get-ADGroupMember -Identity $textbox1.Text -Recursive -ErrorAction 'Stop'
			}
			catch {
				$statusbar1.Text = $Error[0]
				return
			}
		}
		else {
			try {
				$GroupMembers = Get-ADGroupMember -Identity $textbox1.Text -ErrorAction 'Stop'
			}
			catch {
				$statusbar1.Text = $Error[0]
				return
			}
		}
		try {
			$GroupMembers | Get-ADUser -Properties DisplayName, LastLogonDate, mail, manager, Description -ErrorAction 'SilentlyContinue' | Export-Csv $textboxFile.Text -Delimiter ";" -Encoding utf8 -NoTypeInformation -ErrorAction 'Stop'
		}
		catch {
			$statusbar1.Text = $Error[0]
			return
		}
		
		$statusbar1.Text = "$($GroupMembers.count) members exported."
	}
	
	$buttonBrowseFolder_Click={
		if($savefiledialog1.ShowDialog() -eq 'OK')
		{
			$textboxFile.Text = $savefiledialog1.FileName
		}
	}
	
	$buttonExportTreeStructure_Click={
		#TODO: Place custom script here
		
		$statusbar1.Text = "Working..."
		
		function Get-GroupStructure
		{
		    param ([string] $GroupPath = '',
		           [string] $GroupName)
	
		    $GroupMembers = @()
		    $GroupMembers += Get-ADGroupMember $GroupName | Sort-Object objectClass -Descending
	
		    $LoopCount = @($GroupPath -split " \\ " | Where-Object { $_ -eq $GroupName })
	
		    if ($LoopCount.Count -ge 2) {
		        Write-Error "Nested group loop detected. Group: $GroupName"
		        return;
		    }
	
		    if ($GroupPath -eq '') {
		        $GroupPath = "$GroupName \ "
		    }
	
		    if ($GroupMembers.Count -eq 0) {
		        Write-Output $GroupPath
		    }
	
		    foreach($GroupMember in $GroupMembers) {
		        
		        Remove-Variable DrilledDownGroupPath, UserPath -ErrorAction SilentlyContinue
	
		        if ($GroupMember.objectClass -eq 'group') {
		            $DrilledDownGroupPath = $GroupPath + "$($GroupMember.name) \ "
		            Get-GroupStructure -GroupPath $DrilledDownGroupPath -GroupName $GroupMember.name
		        }
		        else {
		            $UserPath = "$GroupPath$($GroupMember.Name) ($($GroupMember.SamAccountName))"
		            Write-Output $UserPath
		        }
		    }
		}
		
		try {
			$Structure = Get-GroupStructure -GroupName $textbox1.Text
		}
		catch {
			$statusbar1.Text = $Error[0]
			return
		}
		
		try {
			$Structure | Sort-Object -ErrorAction 'Stop' | Out-File $textboxFile.Text -Encoding utf8 -ErrorAction 'Stop'
		}
		catch {
			$statusbar1.Text = $Error[0]
			return
		}
		
		$statusbar1.Text = "Group tree structure exported."
	}
	
	# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$formExportGroupMembers.WindowState = $InitialFormWindowState
	}
	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$buttonExportTreeStructure.remove_Click($buttonExportTreeStructure_Click)
			$buttonBrowseFolder.remove_Click($buttonBrowseFolder_Click)
			$buttonExportMembers.remove_Click($buttonExportMembers_Click)
			$formExportGroupMembers.remove_Load($formExportGroupMembers_Load)
			$formExportGroupMembers.remove_Load($Form_StateCorrection_Load)
			$formExportGroupMembers.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch [Exception]
		{ }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	#
	# formExportGroupMembers
	#
	$formExportGroupMembers.Controls.Add($buttonExportTreeStructure)
	$formExportGroupMembers.Controls.Add($buttonBrowseFolder)
	$formExportGroupMembers.Controls.Add($textboxFile)
	$formExportGroupMembers.Controls.Add($buttonExportMembers)
	$formExportGroupMembers.Controls.Add($labelSaveTo)
	$formExportGroupMembers.Controls.Add($statusbar1)
	$formExportGroupMembers.Controls.Add($checkboxRecursive)
	$formExportGroupMembers.Controls.Add($labelADGroupName)
	$formExportGroupMembers.Controls.Add($textbox1)
	$formExportGroupMembers.ClientSize = '372, 188'
	$formExportGroupMembers.FormBorderStyle = 'Fixed3D'
	$formExportGroupMembers.Name = "formExportGroupMembers"
	$formExportGroupMembers.Text = "Export group members"
	$formExportGroupMembers.add_Load($formExportGroupMembers_Load)
	#
	# buttonExportTreeStructure
	#
	$buttonExportTreeStructure.Location = '283, 126'
	$buttonExportTreeStructure.Name = "buttonExportTreeStructure"
	$buttonExportTreeStructure.Size = '81, 34'
	$buttonExportTreeStructure.TabIndex = 6
	$buttonExportTreeStructure.Text = "Export tree structure"
	$buttonExportTreeStructure.UseVisualStyleBackColor = $True
	$buttonExportTreeStructure.add_Click($buttonExportTreeStructure_Click)
	#
	# buttonBrowseFolder
	#
	$buttonBrowseFolder.Location = '247, 94'
	$buttonBrowseFolder.Name = "buttonBrowseFolder"
	$buttonBrowseFolder.Size = '30, 23'
	$buttonBrowseFolder.TabIndex = 4
	$buttonBrowseFolder.Text = "..."
	$buttonBrowseFolder.UseVisualStyleBackColor = $True
	$buttonBrowseFolder.add_Click($buttonBrowseFolder_Click)
	#
	# textboxFile
	#
	$textboxFile.AutoCompleteMode = 'SuggestAppend'
	$textboxFile.AutoCompleteSource = 'FileSystemDirectories'
	$textboxFile.Location = '13, 96'
	$textboxFile.Name = "textboxFile"
	$textboxFile.Size = '228, 20'
	$textboxFile.TabIndex = 3
	#
	# buttonExportMembers
	#
	$buttonExportMembers.Location = '283, 88'
	$buttonExportMembers.Name = "buttonExportMembers"
	$buttonExportMembers.Size = '81, 34'
	$buttonExportMembers.TabIndex = 5
	$buttonExportMembers.Text = "Export members"
	$buttonExportMembers.UseVisualStyleBackColor = $True
	$buttonExportMembers.add_Click($buttonExportMembers_Click)
	#
	# labelSaveTo
	#
	$labelSaveTo.Location = '13, 72'
	$labelSaveTo.Name = "labelSaveTo"
	$labelSaveTo.Size = '100, 23'
	$labelSaveTo.TabIndex = 4
	$labelSaveTo.Text = "Save to:"
	#
	# statusbar1
	#
	$statusbar1.Location = '0, 166'
	$statusbar1.Name = "statusbar1"
	$statusbar1.Size = '372, 22'
	$statusbar1.TabIndex = 3
	#
	# checkboxRecursive
	#
	$checkboxRecursive.Checked = $True
	$checkboxRecursive.CheckState = 'Checked'
	$checkboxRecursive.Location = '283, 40'
	$checkboxRecursive.Name = "checkboxRecursive"
	$checkboxRecursive.Size = '81, 24'
	$checkboxRecursive.TabIndex = 2
	$checkboxRecursive.Text = "Recursive"
	$checkboxRecursive.UseVisualStyleBackColor = $True
	#
	# labelADGroupName
	#
	$labelADGroupName.Location = '12, 11'
	$labelADGroupName.Name = "labelADGroupName"
	$labelADGroupName.Size = '265, 23'
	$labelADGroupName.TabIndex = 1
	$labelADGroupName.Text = "AD group name:"
	#
	# textbox1
	#
	$textbox1.Location = '12, 40'
	$textbox1.Name = "textbox1"
	$textbox1.Size = '265, 20'
	$textbox1.TabIndex = 0
	#
	# openfiledialog1
	#
	$openfiledialog1.DefaultExt = "txt"
	$openfiledialog1.Filter = "Text File (.txt)|*.txt|All Files|*.*"
	$openfiledialog1.ShowHelp = $True
	#
	# folderbrowserdialog1
	#
	#
	# savefiledialog1
	#
	$savefiledialog1.DefaultExt = "csv"
	$savefiledialog1.Filter = "*.csv|All files"
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $formExportGroupMembers.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$formExportGroupMembers.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$formExportGroupMembers.add_FormClosed($Form_Cleanup_FormClosed)
	#Show the Form
	return $formExportGroupMembers.ShowDialog()

} #End Function

#Call OnApplicationLoad to initialize
if((OnApplicationLoad) -eq $true)
{
	#Call the form
	Call-ExportADGroupMembers_pff | Out-Null
	#Perform cleanup
	OnApplicationExit
}

