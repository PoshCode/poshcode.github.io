function Search-Help($term) {
	Get-Command | Where { Get-Help -full -ea SilentlyContinue $_ |
	    Out-String | Select-String $term }
}

