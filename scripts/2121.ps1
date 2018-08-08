# Original posting on how to access a remote Registry from The Powershell Guy
# 
# http://thepowershellguy.com/blogs/posh/archive/2007/06/20/remote-registry-access-and-creating-new-registry-values-with-powershell.aspx
#
# This script will Query the Uninstall Key on a computer specified in $computername and list the applications installed there
# $Branch contains the branch of the registry being accessed
#  '

# format of Computerlist.csv
# Line 1 - NameOfComputer
# Line 2 etcetc etc etc etc An Actual name of a computer

$COMPUTERS=IMPORT-CSV C:\Powershell\Computerlist.csv

FOREACH ($PC in $COMPUTERS) {
$computername=$PC.NameOfComputer

# Branch of the Registry
$Branch='LocalMachine'

# Main Sub Branch you need to open
$SubBranch="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"

$registry=[microsoft.win32.registrykey]::OpenRemoteBaseKey('Localmachine',$computername)
$registrykey=$registry.OpenSubKey($Subbranch)
$SubKeys=$registrykey.GetSubKeyNames()

# Drill through the list of SubKeys and examine the Display name

Foreach ($key in $subkeys)
{
    $exactkey=$key
    $NewSubKey=$SubBranch+"\\"+$exactkey
    $ReadUninstall=$registry.OpenSubKey($NewSubKey)
    $Value=$ReadUninstall.GetValue("DisplayName")
    Write-Host $computername, $Value
 
}

