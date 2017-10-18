########################################################
# Modifies the default PowerGUI admin console
# welcome screen to the mht file you supply
# Details available at:
# http://dmitrysotnikov.wordpress.com/2009/02/11/rebranding-powergui-consolerebranding-powergui-console/ 
########################################################
# Usage:
# & .\Set-PowerGUIWelcomePage.ps1 \\server\share\my.mht
########################################################
# (c) Dmitry Sotnikov, Oleg Shevnin
# v1, Feb 11, 2009
########################################################

param ($mhtpath)
# this should be path (local or UNC) to the new welcome page

# verify that the new file exists and is mht
if ( $mhtpath -eq $null ) {
	$mhtpath = Read-Host "Please provide path to the MHT file."
}
$mhtfile = Get-ChildItem $mhtpath
if ( $mhtfile -eq $null) { 
	throw "MHT file $mhtpath not found. Please verify the script parameter." 
}
if ( $mhtfile.Extension -ne ".mht" ) {
	throw "File $mhtpath is not an MHT file. Only MHT files are supported." 
}

# Locate PowerGUI configuration for current user on this computer
$cfgpath = "$($env:APPDATA)\Quest Software\PowerGUI\quest.powergui.xml"

# Create backup
Copy-Item $cfgpath "$cfgpath.backupconfig"

# Read the file
$xml = [xml]$(Get-Content $cfgpath)

# If the section for custom welcome page does not exist - create it
$node = $xml.SelectSingleNode("//container[@id='4b510268-a4eb-42e0-9276-06223660291d']")
if ($node -eq $null) {
	$node = $xml.CreateElement("container")
	
	$node.SetAttribute("id", "4b510268-a4eb-42e0-9276-06223660291d")
	$node.SetAttribute("name", "Home Page")
	
	$node.AppendChild($xml.CreateElement("value"))
	$xml.SelectSingleNode("/configuration/items").AppendChild($node)
}

# Set the new value and save the file
$node.Value = $mhtpath
$xml.Save($cfgpath)
