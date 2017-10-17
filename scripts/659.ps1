###
# TruncatePath
# Version 1.0.6 (05 Nov 2008)
# Description: Replaces long provider paths in the prompt with ellipses
# Notes: Place in your profile
# 
# By Mike Hays, http://www.mike-hays.net
###

$maxPathLength = 40
$showFullPath = $false
Function Prompt
{
	$currentPath = (Get-Location).Path

	if ( ($currentPath.Length -gt $maxPathLength) -and ($showFullPath -ne $true) -and (($currentPath.Split("\")).Count -gt 3) )
	{
		$currentPathSplit = $currentPath.Split("\")
		$truncatedPath = $currentPathSplit[0] + "\" + $currentPathSplit[1] + "\" + "..." + "\" + `
			$currentPathSplit[$currentPathSplit.Length - 1]

		if ($truncatedPath.Length -lt $currentPath.Length)
		{
			$displayPath = $truncatedPath
		}
		else
		{
			$displayPath = get-location
		}
	}
	else
	{
		$displayPath = get-location
	}

    Write-Host ("PS ") -NoNewLine -ForegroundColor DarkYellow ; Write-Host ("" + $displayPath + ">") -NoNewLine
	return " "
}
