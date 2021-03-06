#This script is designed to set a test server to use a specific directory for App-V Apps, to enable testing
#Without having to publish to an external repository.
#REQUIREMENTS: Windows 2008

##FUNCTIONS
# DESCRIPTION: Displays the attention message box & checks to see if the user clicks the ok button.
function Show-MessageBox ($title, $msg) {	
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	[Windows.Forms.MessageBox]::Show($msg, $title, [Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning, [System.Windows.Forms.MessageBoxDefaultButton]::Button1, [System.Windows.Forms.MessageBoxOptions]::DefaultDesktopOnly) | Out-Null	
}

function Show-InformationBox ([string]$Title,[string]$Message) {
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	[Windows.Forms.MessageBox]::Show($Message, $Title, [Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information, [System.Windows.Forms.MessageBoxDefaultButton]::Button1, [System.Windows.Forms.MessageBoxOptions]::DefaultDesktopOnly) | Out-Null	
}

##VARIABLES
#App-V Test Repository
$Repository = "\\server\share\AppVRepository\2-TestPackages"

#App-V Client Registry Path
$AppVRegRoot = "HKLM:\SOFTWARE\Microsoft\SoftGrid\4.5\Client"

# Different App-V Client Registry for x64 systems
if ((Get-WMIObject win32_operatingsystem).OSArchitecture -match "64-bit") {
	$AppVRegRoot = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\SoftGrid\4.5\Client"
}

##SCRIPT
#Start Transaction
$transEnterAppVTestMode = start-transaction

#Enter AppV Registry Path
set-location $AppVRegRoot

#Get Original App-V Settings
$ASROriginalSetting = (get-itemproperty Configuration).ApplicationSourceRoot
$AIFSOriginalSetting = (get-itemproperty Configuration).AllowIndependentFileStreaming

#Set AppV Variables
set-itemproperty Configuration -name "ApplicationSourceRoot" -value $repository
set-itemproperty Configuration -name "IconSourceRoot" -value $repository

#Delete all App-V Applications
sftmime DELETE obj:app /global

#Get App Manifest Files from Repository and import them
set-location C:
pwd
set-location $repository
pwd
$i=1
get-childitem $repository | where {$_.Name -match "manifest.xml"} | foreach {
	echo $_.Name
	sftmime ADD PACKAGE:TestApp$i /manifest $_.Name /global
	$i++
}

#Display Dialog box that the test mode is active
Show-InformationBox "App-V Testing Mode is active" "Apps will be sourced from $Repository. 

NOTE: File Associations (launching programs by double-clicking their files like .docx) will not be testable due to SCCM vAppLauncher bug

Click OK to return to normal mode"

#Set AppV Variable back to original setting and close script.
set-location $AppVRegRoot
pwd

set-itemproperty Configuration -name "ApplicationSourceRoot" -value ""
set-itemproperty Configuration -name "IconSourceRoot" -value ""

#Delete all App-V Applications
sftmime DELETE obj:app /global
