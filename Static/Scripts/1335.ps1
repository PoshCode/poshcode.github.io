#
# Out-AnsiGraph.psm1
# Author:       xcud
# History:
#       v0.1 September 21, 2009 initial version
#
function Out-AnsiGraph($Parameter1=$null) {
	BEGIN {
		$q = new-object Collections.queue
	}

	PROCESS {
		if($_) {
			$name = $_.($Parameter1[0]);
			$val = $_.($Parameter1[1])
			if($max -lt $val) { $max = $val}		 
			if($namewidth -lt $name.length) { $namewidth = $name.length }
			$q.enqueue(@($name, $val))			
		}
	}

	END {
		$q | %{
			$graph = ""; 0..($_[1]/$max*20) | %{ $graph += "&#9608;" }
			$name = "{0,$namewidth}" -f $_[0]
			"$name $graph " + $_[1]
		}

	}
}

Export-ModuleMember Out-AnsiGraph
