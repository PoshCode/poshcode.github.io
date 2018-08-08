#################################################
# Sample code showing how to save/load PowerShell script
# configuration to disk
#
# (c) Dmitry Sotnikov
# http://dmitrysotnikov.wordpress.com/2010/05/07/storing-powergui-add-on-configuration
#################################################

# Assign unique folder and config names
# This would sore data in
# C:\Users\username\AppData\Roaming\MyPowerGUIAddOn\MyAddOn.Config.xml
$FolderName = "MyPowerGUIAddOn"
$ConfigName = "MyAddOn.Config.xml"

# keep all add-on parameters in a map
$parameters = @{}

# read parameters

if ( Test-Path -Path "$($env:AppData)\$FolderName\$ConfigName") {
	$parameters = Import-Clixml -Path "$($env:AppData)\$FolderName\$ConfigName"
	  
  # now you can use them, e.g.
  $parameters['A']
  $parameters['B']
} else {
  # Config does not exist yet - set defaults
  $parameters['A'] = 5
  $parameters['B'] = "Qwerty"
}

# store parameters

if ( -not (Test-Path -Path "$($env:AppData)\$FolderName")) {
  mkdir "$($env:AppData)\$FolderName"
}
$parameters | Export-Clixml -Path "$($env:AppData)\$FolderName\$ConfigName"
