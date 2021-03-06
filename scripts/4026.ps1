<#
.SYNOPSIS
   This is a powershell script form to remove a users local profile from a workstation and
   and gives the option to remove the users profile fromt he network.
.DESCRIPTION
   This script askes for a machine name.
   It displays all of the roaming profiles on that machine.
   The administrator selects the profile to be removed from the machine.
   The administrator selects whether the network profile is to be removed as well.
   The administrator clicks the delete button and the script removes the local profile
   and the network profile if the option was seleteced.
.NOTES
   This script must be run as with adminstrator credentials.
   Created: 08/03/13
#>

CLS

Import-Module ActiveDirectory

# Define Variables
$global:Workstation = ""


function CheckCredentials
{
	# Check Credentials
	$Credential = ([Security.Principal.WindowsIdentity]::GetCurrent()).Name
	$CredentialTest = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
	if($CredentialTest -eq $false)
	{
		[System.Windows.Forms.MessageBox]::Show("You are not an Administrator.`n`nPlease run the script with `nAdministrator credentials." , "Not an Administrator!" , 0)
		$objForm.Close()
	}
}

function TestWMIConnection
{
	# Test WMI Connection and update label
	if(!(Get-WmiObject -class "Win32_Process" -namespace "root\cimv2" -ComputerName $Workstation -ErrorAction SilentlyContinue))
	{
		$WMIConnectionLabel.ForeColor = "Red"
		$WMIConnectionLabel.Text = "WMI Connection to device is DOWN."
	}
	else
	{
		$WMIConnectionLabel.ForeColor = "Green"
		$WMIConnectionLabel.Text = "WMI Connection to device is OK."
	}
}

function GetLocalProfiles
{
		$ProfilesFoundListBox.Items.Clear()
		$ProfileDetailsRichTextBox.Text = ""
		$Profiles = ""
		
		$Profiles = @(Get-WmiObject -Class Win32_UserProfile -ComputerName $Workstation -ErrorAction SilentlyContinue | ?{$_.Status -eq "2"})
		# Profile Status values are (0, 1, 2, 4, 8) where a value of zero denotes unset or default
		# and 1 = Temporary, 2 = Roaming, 4 = Mandatory and 8 = Corrupted.
		
		foreach($Profile in $Profiles)
		{
			$objSID = New-Object System.Security.Principal.SecurityIdentifier($Profile.sid)
			$objUser = $objSID.Translate([System.Security.Principal.NTAccount])
			$Profilename = $objUser.value.split("\")[1]
			$ProfilesFoundListBox.Items.Add($Profilename.ToUpper())
			$objForm.Update()
		}
}

function GetProfileDetails
{
	# Get AD Account Info
	$ADInfo = ""
	$LocalProfile = ""
	
	$ADUserID = Get-ADUser -Identity $ProfilesFoundListBox.SelectedItem -Properties *
	
	$ProfileInfo = "Active Directory Details:"
	$ProfileInfo = $ProfileInfo + "`nName    : " + $ADUserID.displayNamePrintable
	$ProfileInfo = $ProfileInfo + "`nOffice  : " + $ADUserID.Office
	$ProfileInfo = $ProfileInfo + "`nStaff ID: " + $ADUserID.EmployeeID
	$ProfileInfo = $ProfileInfo + "`nProfile : " + $ADUserID.ProfilePath
	
	# Get Local Profile Info
	$LocalProfile = Get-WmiObject -Class Win32_UserProfile -ComputerName $Workstation -ErrorAction SilentlyContinue | ?{$_.LocalPath -like "*" + $ProfilesFoundListBox.SelectedItem}
	try
	{
		$LastDownloadTime = $LocalProfile.ConvertToDateTime($LocalProfile.LastDownloadTime).ToShortDateString()
	}
	catch
	{
		$LastDownloadTime = "Never Downloaded"
	}
	$LastUsedTime = $LocalProfile.ConvertToDateTime($LocalProfile.LastUseTime).ToShortDateString()
	
	$ProfileInfo = $ProfileInfo + "`n`nLocal Profile Details:"
	$ProfileInfo = $ProfileInfo + "`nProfile Path  : " + $LocalProfile.LocalPath
	$ProfileInfo = $ProfileInfo + "`nLast Download : " + $LastDownloadTime
	$ProfileInfo = $ProfileInfo + "`nLast Used     : " + $LastUsedTime
	$ProfileInfo = $ProfileInfo + "`nIs Loaded     : " + $LocalProfile.Loaded
	
	$ProfileDetailsRichTextBox.Text = $ProfileInfo
	
	if($LocalProfile.Loaded -eq $true)
	{
		[System.Windows.Forms.MessageBox]::Show("The selected profile is currently loaded.`nThe profile will need to be logged off.", "Profile Loaded" , 0)
	}
	
}

function DeleteLocalProfile
{
	$ConfirmDelete = [System.Windows.Forms.MessageBox]::Show("CONFIRM`n`nDelete local profile :   " + $ProfilesFoundListBox.SelectedItem + "`nFrom Workstation  :   " + $Workstation.ToUpper() , "Local Profile Delete" , 4)
	if ($ConfirmDelete -eq "YES")
	{
		Get-WmiObject -Class Win32_UserProfile -ComputerName $Workstation -ErrorAction SilentlyContinue | ?{$_.LocalPath -like "*" + $ProfilesFoundListBox.SelectedItem} | Remove-WmiObject
		[System.Windows.Forms.MessageBox]::Show("Profile "+ $ProfilesFoundListBox.SelectedItem + " has been deleted from " + $Workstation + ".", "Profile Deleted" , 0)
	}
}

function DeleteNetworkProfile
{
	$ADUserID = Get-ADUser -Identity $ProfilesFoundListBox.SelectedItem -Properties *
	$ConfirmDelete = [System.Windows.Forms.MessageBox]::Show("CONFIRM`n`nDelete network profile :  " + $ADUserID.displayNamePrintable + "`nPath :  " + $ADUserID.ProfilePath , "Network Profile Delete" , 4)
	if ($ConfirmDelete -eq "YES")
	{
		$NetProfile = $ADUserID.ProfilePath
		$NetProfile = [string]::Join('\', $NetProfile.Split('\')[0..$($NetProfile.Split('\').Length-2)])
		Remove-Item $NetProfile -Recurse -Force
		[System.Windows.Forms.MessageBox]::Show("Network profile has been deleted.`n" + "Path :  " + $NetProfile , "Profile Deleted" , 0)
	}
	else
	{
		$objForm.Close()
	}
}

Function BuildForm
{
	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
	[void] [System.Windows.Forms.Application]::EnableVisualStyles()
	
	$objForm = New-Object System.Windows.Forms.Form 
	$objForm.Text = "Remove Profile Tool"
	$objForm.Icon = [system.drawing.icon]::ExtractAssociatedIcon($PsHome + "\powershell.exe")
	$objForm.Size = New-Object System.Drawing.Size(550,500) 
	$objForm.StartPosition = "CenterScreen"
	$objForm.AutoSize = $True
	$objForm.AutoSizeMode = "GrowOnly" # GrowAndShrink or GrowOnly
	$objForm.AutoScroll = $True
	$objForm.MinimizeBox = $true
	$objForm.MaximizeBox = $False
	$objForm.WindowState = "Normal" # Maximized, Minimized, Normal
	$objForm.SizeGripStyle = "Hide" # Auto, Hide, Show
	$objForm.ShowInTaskbar = $true
	$objForm.Topmost = $True
	$objFormFont1 = New-Object System.Drawing.Font("Arial",24,[System.Drawing.FontStyle]::Regular)          # Form title font
	$objFormFont2 = New-Object System.Drawing.Font("Arial",10,[System.Drawing.FontStyle]::Regular)          # Form font
	$objFormFont3 = New-Object System.Drawing.Font("Consolas",10,[System.Drawing.FontStyle]::Regular)       # Fixed width font
#	$objFormFont3 = New-Object System.Drawing.Font("Lucida Console",10,[System.Drawing.FontStyle]::Regular) # Second fixed width font

	# Font styles are: Regular, Bold, Italic, Underline, Strikeout
	$objForm.Font = $objFormFont2 # Applies font to whole form
	
	$objForm.KeyPreview = $True
#	$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter"){$x=$objTextBox.Text;$objForm.Close()}})
	$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape"){$objForm.Close()}})
	
	# Form Objects
	# Check Credentials
	CheckCredentials
	
	#Form Title
	$FormTitleLabel = New-Object System.Windows.Forms.Label
	$FormTitleLabel.Location = New-Object System.Drawing.Size(10,10)
	$FormTitleLabel.Autosize = $true # = New-Object System.Drawing.Size(650,40)
	$FormTitleLabel.Font = $objFormFont1
	$FormTitleLabel.Text = "Profile Removal Tool"
	$objForm.Controls.Add($FormTitleLabel)
	
	
	#Get Workstation Name
	$GetWorkstationNameLabel = New-Object System.Windows.Forms.Label
	$GetWorkstationNameLabel.Location = New-Object System.Drawing.Size(10,70)
	$GetWorkstationNameLabel.Size = New-Object System.Drawing.Size(140,20)
	$GetWorkstationNameLabel.Text = "Enter Machine Name"
	$objForm.Controls.Add($GetWorkstationNameLabel)
	
	$GetWorkstationNameTextBox = New-Object System.Windows.Forms.TextBox
	$GetWorkstationNameTextBox.Location = New-Object System.Drawing.Size(155,69) # Count as (160,70) -1 to align text box
	$GetWorkstationNameTextBox.Size = New-Object System.Drawing.Size(140,20)
	$objForm.Controls.Add($GetWorkstationNameTextBox)
	
	$GetWorkstationNameButton = New-Object System.Windows.Forms.Button
	$GetWorkstationNameButton.Location = New-Object System.Drawing.Size(305,69) # Count as (305,70) -1 to align button
	$GetWorkstationNameButton.Size = New-Object System.Drawing.Size(75,23)
	$GetWorkstationNameButton.Text = "OK"
	$GetWorkstationNameButton.Add_Click(
	{
		$Workstation = $GetWorkstationNameTextBox.Text.ToUpper()
		
		# Update profiles found label
		$ProfilesFoundLabel.Text = "Profiles found on " + $Workstation
		$objForm.Controls.Add($ProfilesFoundLabel)
		
		# Test WMI Connection
		TestWMIConnection
		
		# Get local profiles
		GetLocalProfiles		
	})
	$objForm.Controls.Add($GetWorkstationNameButton)
	
	#WMI Connection Status
	$WMIConnectionLabel = New-Object System.Windows.Forms.Label
	$WMIConnectionLabel.Location = New-Object System.Drawing.Size(10,115)
	$WMIConnectionLabel.Size = New-Object System.Drawing.Size(280,20)
	$WMIConnectionLabel.Text = "WMI Connection to device is..."
	$objForm.Controls.Add($WMIConnectionLabel)
	
	# Found Profiles
	$ProfilesFoundLabel = New-Object System.Windows.Forms.Label
	$ProfilesFoundLabel.Location = New-Object System.Drawing.Size(10,150)
	$ProfilesFoundLabel.Size = New-Object System.Drawing.Size(280,20)
	$ProfilesFoundLabel.Text = "Profiles found on..."
	$objForm.Controls.Add($ProfilesFoundLabel)

	$ProfilesFoundListBox = New-Object System.Windows.Forms.ListBox
	$ProfilesFoundListBox.Location = New-Object System.Drawing.Size(10,180)
	$ProfilesFoundListBox.Size = New-Object System.Drawing.Size(280,200)
	$ProfilesFoundListBox.Text = "Found Profiles"
	$ProfilesFoundListBox.Add_Click(
	{
		GetProfileDetails
	})
	$objForm.Controls.Add($ProfilesFoundListBox)
	
	# Profile Details
	$ProfileDetailsLabel = New-Object System.Windows.Forms.Label
	$ProfileDetailsLabel.Location = New-Object System.Drawing.Size(305,150)
	$ProfileDetailsLabel.Size = New-Object System.Drawing.Size(280,20)
	$ProfileDetailsLabel.Text = "Profile Details"
	$objForm.Controls.Add($ProfileDetailsLabel)

	$ProfileDetailsRichTextBox = New-Object System.Windows.Forms.RichTextBox
	$ProfileDetailsRichTextBox.Location = New-Object System.Drawing.Size(305,180)
	$ProfileDetailsRichTextBox.Size = New-Object System.Drawing.Size(280,200)
	$ProfileDetailsRichTextBox.Font = $objFormFont3
	$ProfileDetailsRichTextBox.ForeColor = "DarkGreen"
	$objForm.Controls.Add($ProfileDetailsRichTextBox)
	
	# Delete network profile checkbox
	$DeleteNetProfileCheckBox = New-Object System.Windows.Forms.CheckBox
	$DeleteNetProfileCheckBox.Location = New-Object System.Drawing.Size(10,390) 
	$DeleteNetProfileCheckBox.Size = New-Object System.Drawing.Size(280,20) 
	$DeleteNetProfileCheckBox.Text = "Include Network Profile in Delete"
	$DeleteNetProfileCheckBox.ForeColor = "Red"
	$objForm.Controls.Add($DeleteNetProfileCheckBox) 
	
	# Delete button
	$DeleteButton = New-Object System.Windows.Forms.Button
	$DeleteButton.Location = New-Object System.Drawing.Size(10,430)
	$DeleteButton.Size = New-Object System.Drawing.Size(135,23)
	$DeleteButton.Text = "Delete"
	$DeleteButton.BackColor = "Red"
	$DeleteButton.Forecolor = "White"
	$DeleteButton.Add_Click(
	{
		DeleteLocalProfile
		
		if($DeleteNetProfileCheckBox.Checked)
		{
			DeleteNetworkProfile
		}
		
		# Update profile info
		GetLocalProfiles

	})
	$objForm.Controls.Add($DeleteButton)
	
	$ExitButton = New-Object System.Windows.Forms.Button
	$ExitButton.Location = New-Object System.Drawing.Size(155,430)
	$ExitButton.Size = New-Object System.Drawing.Size(135,23)
	$ExitButton.Text = "Exit"
	$ExitButton.Add_Click({$objForm.Close()})
	$objForm.Controls.Add($ExitButton)
	
	# Status Line
	$StatusLineLabel = New-Object System.Windows.Forms.Label
	$StatusLineLabel.Location = New-Object System.Drawing.Size(415,430) 
	$StatusLineLabel.Size = New-Object System.Drawing.Size(180,40) 
	$StatusLineLabel.Text = "Version       : 2.02"
	$objForm.Controls.Add($StatusLineLabel) 

	# Show Form
	$objForm.Add_Shown({$objForm.Activate()})
	[void] $objForm.ShowDialog()
} # End Function


# Application Start
BuildForm

