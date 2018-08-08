#
# Out-AnsiGraph.psm1
# Author:       xcud
# History:
#       v0.1 September 21, 2009 initial version
#
# PS Example> ps | select -first 5 | sort -property VM | Out-AnsiGraph ProcessName, VM
#                 AEADISRV &#9608;&#9608;&#9608; 14508032
#                  audiodg &#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608; 50757632
#                  conhost &#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608; 73740288
# AppleMobileDeviceService &#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608; 92061696
#                    btdna &#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608; 126443520
#
function Out-AnsiGraph($Parameter1=$null, $inputObject=$null) {
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
