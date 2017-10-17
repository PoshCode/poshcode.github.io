function gather {
#.SYNOPSIS
#  Port of Perl 6's gather/take (which itself is a port of Mathematica's Reap/Sow)
#.EXAMPLE
#  gather { 1 ; take 2 ; 3 ; take 4 5 }
#  2
#  4
#  5
#.NOTES
#  PowerShell doesn't really need this since the pipeline does this by default
#  (and does a much better job since it works by using a push streaming model)
#  but it's useful in the rare cases that it's necessary.
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[scriptblock]$Script
	)
	try {
		${function:take} = (New-Object System.Management.Automation.PSModuleInfo $true).NewBoundScriptBlock({ $script:acc.AddRange($args) })
		& ${function:take}.Module { $script:acc = [System.Collections.ArrayList]@() }
	} catch {
		throw
	}
	$null = & $Script
	& ${function:take}.Module { $script:acc }
}
