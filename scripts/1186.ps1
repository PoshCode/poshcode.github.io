# detect source control management software
function findscm {
	$scm = ''
	:selectscm foreach ($_ in @('svn', 'hg')) {
		$dir = (Get-Location).ProviderPath.trimEnd("\")
		while ($dir.Length -gt 3) {			
			if (Test-Path ([IO.Path]::combine(($dir), ".$_"))) {			
				$scm = $_
				break selectscm
			}
			$dir = $dir -Replace '\\[^\\]+$', ''
		}
	}
	return $scm
}

# draw output
function drawlines($colors, $cmd) {
	$scm = findscm
	if (!$cmd -or !$scm) { return }
	foreach ($line in (&$scm ($cmd).split())) {
		$color = $colors[[string]$line[0]]
		if ($color) {
			write-host $line -Fore $color
		} else {
			write-host $line
		}
	}
}

# svn stat
function st {
	drawlines @{ "A"="Magenta"; "D"="Red"; "C"="Yellow"; "G"="Blue"; "M"="Cyan"; "U"="Green"; "?"="DarkGray"; "!"="DarkRed" } "stat $args"
}

# svn update
function su {
	drawlines @{ "A"="Magenta"; "D"="Red"; "U"="Green"; "C"="Yellow"; "G"="Blue"; } "up $args"
}

# svn diff
function sd {
	drawlines @{ "@"="Magenta"; "-"="Red"; "+"="Green"; "="="DarkGray"; } "diff $args" 
}
