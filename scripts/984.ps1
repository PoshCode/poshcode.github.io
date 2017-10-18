########################################################
# Modifies the default PowerGUI admin console
# welcome screen to the mht file you supply
# Details available at:
# http://dmitrysotnikov.wordpress.com/2009/02/11/rebranding-powergui-consolerebranding-powergui-console/ 
########################################################
# Usage:
# To change the homepage:
#   & .\Set-PowerGUIWelcomePage.ps1 \\server\share\my.mht
# To rollback the change:
#   & .\Set-PowerGUIWelcomePage.ps1 -ResetToDefault $true
########################################################
# (c) Dmitry Sotnikov, Oleg Shevnin
#  1.2 - Mar 30:
#   added parameter to reset home page to default
#   fixed the issue which aroused when path was supplied interactively
#  1.1 - Mar 17: added exception if PowerGUI Admin Console is running
#  v1, Feb 11, 2009
#
########################################################

param ([string] $mhtpath, [bool] $ResetToDefault = $false)
# this should be path (local or UNC) to the new welcome page

# make sure that the admin console is closed
if (( get-process Quest.PowerGUI -ErrorAction SilentlyContinue ) -ne $null) { 
	throw "Please close the PowerGUI administrative console before running this script" 
}

# Locate PowerGUI configuration for current user on this computer
$cfgpath = "$($env:APPDATA)\Quest Software\PowerGUI\quest.powergui.xml"

# Create backup
Copy-Item $cfgpath "$cfgpath.backupconfig"

# Read the file
$xml = [xml]$(Get-Content $cfgpath)


# check if this is run to roll back the changes or to introduced them
if ( $ResetToDefault ) {

	# Locate the custom homepage section
	$node = $xml.SelectSingleNode("//container[@id='4b510268-a4eb-42e0-9276-06223660291d']")
	if ($node -eq $null) {
		"Configuration is already using default homepage. No rollback required."
	} else {
		$xml.SelectSingleNode("/configuration/items").RemoveChild($node) | Out-Null 
		$xml.Save($cfgpath)
		"SUCCESS: Successfully rolled PowerGUI back to default welcome page."
	}
		
} else {

	# change the welcome screen to the mht supplied as parameter
	
	# verify that the new file exists and is mht
	if ( $mhtpath -eq $null ) {
		$mhtpath = Read-Host "Please provide path to the MHT file"
	}
	$mhtfile = Get-ChildItem $mhtpath
	if ( $mhtfile -eq $null) { 
		throw "MHT file $mhtpath not found. Please verify the script parameter." 
	}
	if ( $mhtfile.Extension -ne ".mht" ) {
		throw "File $mhtpath is not an MHT file. Only MHT files are supported." 
	}
	
	
	# If the section for custom welcome page does not exist - create it
	$node = $xml.SelectSingleNode("//container[@id='4b510268-a4eb-42e0-9276-06223660291d']")
	if ($node -eq $null) {
		$node = $xml.CreateElement("container")
		
		$node.SetAttribute("id", "4b510268-a4eb-42e0-9276-06223660291d")
		$node.SetAttribute("name", "Home Page")
		
		$node.AppendChild($xml.CreateElement("value")) | Out-Null 
		$xml.SelectSingleNode("/configuration/items").AppendChild($node) | Out-Null 
	}
	
	# Set the new value and save the file
	$node.Value = [String] $mhtpath
	$xml.Save($cfgpath)
	"SUCCESS: $mhtpath is now set as your custom welcome screen."
}
