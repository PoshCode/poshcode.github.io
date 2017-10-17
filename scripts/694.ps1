######################################################
# Script to remove unauthorized objects from AD group
# (c) Josh Coen
# Requires AD cmdlets
######################################################

# set path and file name in $strFile
# file should contain authorized usernames or groups one on each line
# set group you want to check in $strGroup


$ErrorActionPreference = "SilentlyContinue"
$strFile = "c:\admins.txt"
$testFile = Test-Path $strFile
$aryAuth = Get-Content $strFile
$strGroup = "Domain Admins"
$colItems = Get-QADGroupMember $strGroup
$intItem = 0
$intFile = 0
$match = 0

if ($testFile -eq $false) 
{
	"`n `n File Not Found: $strFile -- exiting script `n`n"
	break
}

while ($intItem -lt $colItems.Length)
{
	while ($intFile -lt $aryAuth.Length)
{
		$strType = $colItems[$intItem].type
		switch ($strType)
{
			user {$exists = $colItems[$intItem].logonname -match $aryAuth[$intFile]}
			group {$exists = $colItems[$intItem].name -match $aryAuth[$intFile]}
		}
		if ($exists -eq $false)
{
			$match ++ 
		}
		$intFile ++ 
	}
	if ($match -eq $aryAuth.length)
{
		Remove-QADGroupMember -Identity $strGroup -Member $colItems[$intItem]
	}
	$match = 0
	$intFile = 0
	$intItem ++ 
} 


