function Write-Choice {
	param($prompt, $choice)

	write-host -n "["
	write-host -n -f yellow $prompt
	write-host "]", $choice
	Write-Output $prompt
}

function Get-Selection {
	param(
	[Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0,HelpMessage="Choices")]
	[Object]
	$choice,

	[Parameter(HelpMessage="Intro message")]
	[string]
	$introMessage="Choose from the following options:",
	
	[Parameter(HelpMessage="Prompt message")]
	[string]
	$prompt="Select an option",

	[Parameter(HelpMessage="Window size")]
	[Int]
	$windowSize=10
	)

	$currentWindow = 0
	$maxWindow = [Math]::Floor($choice.length / $windowSize)
	while ($true) {
		Clear-Host
		$start = $currentWindow*$windowSize
		$thisWindowSize = [Math]::Min($windowSize, $choice.length - $start)
		if ($introMessage) {
			write-host -fore yellow $introMessage
		}
		$choices = @()
		for ($i = 1; $i -lt $thisWindowSize + 1; $i++) {
			$choices += Write-Choice $i $choice[$start + $i - 1]
		}
		if ($currentWindow -gt 0) {
			$choices += Write-Choice "P" "Previous Page Of Choices"
		}
		if ($currentWindow -lt $maxWindow) {
			$choices += Write-Choice "N" "Next Page Of Choices"
		}

		while ($true) {
			$input = read-host $prompt
			if ($choices -notcontains $input) {
				continue
			}
			if ($input -eq "N") {
				$currentWindow++
				break
			} elseif ($input -eq "P") {
				$currentWindow--
				break
			} else {
				Write-Output $choice[$start + [int]$input - 1]
				return
			}
		}
	}
}

# Example 1
# $choices = 1..25
# Get-Selection $choices

# Example 2
# $choices = Get-Childitem c:\windows\system32
# Get-Selection $choices -windowsize 20 -prompt "Choose a file"
