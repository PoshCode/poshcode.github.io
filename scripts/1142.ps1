#draw output
function drawlines($colors, $lines) {
	foreach ($line in $lines) {
		$color = $colors[[string]$line[0]]
		if ($color) {
			write-host $line -Fore $color
		} else {
			write-host $line
		}
	}
}

# svn stat
function ss {
	drawlines @{ "A"="Magenta"; "D"="Red"; "C"="Yellow"; "G"="Blue"; "M"="Cyan"; "U"="Green"; "?"="DarkGray"; "!"="DarkRed" } (svn stat)
}

# svn update
function su {
	drawlines @{ "A"="Magenta"; "D"="Red"; "U"="Green"; "C"="Yellow"; "G"="Blue"; } (svn up)
}

# svn diff
function sd {
	drawlines @{ "@"="Magenta"; "-"="Red"; "+"="Green"; "="="DarkGray"; } (svn diff)
}
