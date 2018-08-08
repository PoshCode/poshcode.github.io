## SVN STAT colorizer - http://www.overset.com/2008/11/18/colorized-subversion-svn-stat-powershell-function/
function ss () {
	$c = @{ "A"="Magenta"; "D"="Red"; "C"="Yellow"; "G"="Blue"; "M"="Cyan"; "U"="Green"; "?"="DarkGray"; "!"="DarkRed" }
	foreach ( $svno in svn stat ) {  
@@		$color = $c[$svno.SubString(0,1).ToUpper()]
@@		if ( $color ) { 
@@			write-host $svno -Fore $color
		} else { 
			write-host $svno
		}
	}
}


