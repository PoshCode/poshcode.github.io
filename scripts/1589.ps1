###########################################################################"
#
# NAME: GPPreferencesPrinters.psm1
#
# AUTHOR: Jan Egil Ring
# BLOG: http://blog.crayon.no/blogs/janegil
#
# COMMENT: Script module for working with shared printer connections in Group Policy Preferences.
#          Contains a function for adding a shared printer connection, and a function for retrieving shared printer connections from a specified GPO.
#          Requires the Group Policy Automation Engine from SDM Software, available from here (commercial product): http://www.sdmsoftware.com/group_policy_scripting.php
#          Additional functions and parameters will later be added to the script module, i.e. Remove-GPPreferencesPrinter and Item-Level Targeting.
#          Note that example usage for Item-Level Targeting are provided in the Group Policy Automation Engine User Manual.
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the creator, owner above has no warranty, obligations,
# or liability for such use.
#
# VERSION HISTORY:
# 1.0 18.01.2010 - Initial release
#
###########################################################################"

#Imports the Group Policy Automation Engine from SDM Software
Import-Module SDM-GroupPolicy

function Add-GPPreferencesPrinter {
################################################################
#.Synopsis
#  Adds a shared printer connection to the specified Group Policy`s User Preferences.
#.Parameter GPOName
#  The name to the Group Policy Object you want to add the shared printer connection to.
################################################################
param( [Parameter(Mandatory=$true)][string]$GPOName,[Parameter(Mandatory=$true)][string]$Printername,[Parameter(Mandatory=$true)][string]$Sharepath,[Parameter(Mandatory=$true)][string]$Action,[Parameter(Mandatory=$false)][string]$Default,[Parameter(Mandatory=$false)][string]$DefaulIfNoLocalPrinters)

$domain = [System.DirectoryServices.ActiveDirectory.Domain]::getcurrentdomain() 
$domainname = $domain.name
$gpo = Get-SDMgpobject -gpoName "gpo://$domainname/$GPOName" -openByName
$container = $gpo.GetObject("User Configuration/Preferences/Control Panel Settings/Printers/Shared printer")
$add = $container.Settings.AddNew("$Printername")
$add.put("Action",[GPOSDK.EAction]$Action)
$add.put("Share path",$Sharepath)
$add.put("Default",$Default)
$add.put("Default if no local printers",$DefaulIfNoLocalPrinters)
$add.Save()
}

function Get-GPPreferencesPrinter {
################################################################
#.Synopsis
#  Enumerates and displays printer connections defined in the specified Group Policy`s User Preferences.
#.Parameter GPOName
#  The name to the Group Policy Object you want to get information from
################################################################
param(
[Parameter(Mandatory=$true)]
[string]$GPOName
)

$domain = [System.DirectoryServices.ActiveDirectory.Domain]::getcurrentdomain() 
$domainname = $domain.name
$gpo = Get-SDMgpobject -gpoName "gpo://$domainname/$GPOName" -openByName
$container = $gpo.GetObject("User Configuration/Preferences/Control Panel Settings/Printers/Shared printer")
$setting = $container.Settings
$printers =  @()
$count = $setting.Count
$counter = $count; while($counter -ge 1) {$counter = $counter - 1 
$printer = $Setting.Item($counter)
foreach ($i in $printer) {
$printerinfo = @{}
$printerinfo.Name = $i.Name
$printerinfo.Sharepath = ($setting.Item($counter)).Get("Share path")
$printerinfo.Action = ($setting.Item($counter)).Get("Action")
$printerinfo.SetDefault = ($setting.Item($counter)).Get("Default")
$printerinfo.SetDefaulIfNoLocalPrinters = ($setting.Item($counter)).Get("Default if no local printers")
$printers += $printerinfo
}
}
$printers | Select-Object @{Name="Name"; Expression = {$_.name}},@{Name="Sharepath"; Expression = {$_.sharepath}},@{Name="Action"; Expression = {$_.Action}},@{Name="SetDefault"; Expression = {$_.SetDefault}},@{Name="SetDefaulIfNoLocalPrinters"; Expression = {$_.SetDefaulIfNoLocalPrinters}} | ft Name,Sharepath,Action,SetDefault,SetDefaulIfNoLocalPrinters
}
