function New-Closure {
#.SYNOPSIS
#  A more fine grained approach to capturing variables than GetNewClosure
#.EXAMPLE
#  $acc = New-Closure @{t = 0} {param($v = 1) $t += $v; $t} ; & $acc 10 ; & $acc
#  10
#  11
	[OutputType([scriptblock])]
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[System.Collections.IDictionary]$Variable
,
		[Parameter(Mandatory)]
		[scriptblock]$Script
	)
	try {
		$private:m = New-Object System.Management.Automation.PSModuleInfo $true
		$Script = $m.NewBoundScriptBlock($Script)
		foreach ($v in $Variable.GetEnumerator()) {
			& $m { Set-Variable -Name $args[0] -Value $args[1] -Scope script -Option AllScope } $v.Key $v.Value
		}
		$Script
	} catch {
		throw
	}
}
