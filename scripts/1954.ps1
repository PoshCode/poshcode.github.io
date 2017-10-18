function out-colour {
    	if ($Input) {
		[int[]]$columns = @()
		# select colors you prefer and the one that a readable on your console.. :)
		$colours = @('Magenta','Yellow','Cyan','Green')
        	foreach ($obj in ($Input | Out-String -Stream)) {
			if ($columns.count -eq 0) {
				$match = $obj | Select-String -AllMatches -Pattern '[^|\s]-{2,}' | Select-Object -ExpandProperty Matches
				if ( ($match | Measure-Object | Select-Object -ExpandProperty Count) -ge 2) {
					$columns = $match | Select-Object -ExpandProperty Index
				}
				Write-Host $obj
			} else {
				foreach ($char in $obj.ToCharArray()) {
					$colour = $null
					$X = $Host.UI.RawUI.CursorPosition.X
					for ($i=0; $i -lt $columns.count - 1; $i++) {
						Write-Verbose "i = $i ; X = $X"
						if ( ( $X -ge $columns[$i]) -and ( $X -lt $columns[$i+1] ) ) {
							$colour = $colours[($i % $colours.count)]
						}
					}
					if (!$colour) {
						$colour = $colours[(($columns.count -1) % $colours.count)]
					}
                    			Write-Host -ForegroundColor $colour $char -NoNewline
                		}
               		 "`r"
			}
        	}
    	}
}
