function Get-EnumValues ( $EnumType ) {
# Code somewhat stolen from Joel here: https://HuddledMasses.org/ideas-for-writing-composable-powershell-scripts/
	Begin {
		$listItems = @()
	}
	Process {
		if( $_ -is [type] -and $_.IsEnum ) {
			$listItems+= [Enum]::GetValues($_)
		}
		elseif( $_.GetType().IsEnum ) {
			$listItems += [Enum]::GetValues($_.GetType())
		}
		else {
			throw "Input object must be an enumerator type or derived from one."
		}
	}
	End {
		Write-Output $listItems
	}
}
