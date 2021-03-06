<#
	.SYNOPSIS
		Pulls down the leaderboards for the 2011 Scripting Games

	.DESCRIPTION
		Quick and dirty script to pull down the leaderboards for the 2011 scripting games.  
		Can choose either beginner or advanced via a command line switch.
		
	.PARAMETER  Level
		The leaderboard to parse

	.EXAMPLE
		Get-LeaderBoard -Level Beginner
		
		Retrieves the beginner leaderboard.

	.EXAMPLE
		Get-LeaderBoard -Level Advanced
		
		Retrieves the advanced leaderboard

#>

function Get-LeaderBoard 
{
	param(
		[Parameter(
			Position = 0,
			Mandatory = $true,
			HelpMessage = "Leaderboard to parse.  Advanced, or Beginner")]
		[ValidateSet("Advanced","Beginner")]
		[String]$Level="Advanced"
	)
	
	# create a webclient
	$WebClient = New-Object System.Net.WebClient
	# download the page
	$LeaderPage = $WebClient.DownloadString("http://2011sg.poshcode.org/Reports/TopUsers?filter=$Level") 
	
	# create a horrific looking regular expression
	$RegEx = '<a href="/Scripts/By/\d{1,3}">(?<UserName>[\w\s]*)</a>\s*</td>\s*<td>\s*(?<TotalPoints>\d{1,2}\.\d{1,2})\s*</td>\s*<td>\s*(?<ScriptsRated>\d*)'
	
	# split the page into seperate objects so we can parse each invidual
	$LeaderPage -split "<tr>" | ForEach { 
		# match the regex
		$_ -match $RegEx | Out-Null
		# create a new PSObject, supply a hashtable with the properties
		New-Object PSObject -Property @{
			"UserName" = $Matches.UserName
			"ScriptsRated" = $Matches.ScriptsRated
			"TotalPoints" = $Matches.TotalPoints
			"AverageRating" = if  ($Matches.ScriptsRated -gt 0) 
			{
				# get average round to two decimal places
				"{0:N2}" -f ($Matches.TotalPoints / $Matches.ScriptsRated)
			}
		}
		# clear matches
		if ($Matches) { $Matches.Clear() }
		
		# get our objects in a specific order.
	} | select -Unique UserName,ScriptsRated,AverageRating,TotalPoints
}


