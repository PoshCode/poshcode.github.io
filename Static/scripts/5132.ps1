function buffer {
#.SYNOPSIS
#  Like gather/take but for strings
#.PARAMETER Using
#  An already existing StringBuilder to append to
#.EXAMPLE
#  buffer -Separator ' ' { 1 ; take "Hello" ; 3 ; take "World" }
#  Hello World
#.NOTES
#  Use [System.Environment]::NewLine as the Terminator to simulate Out-String
#.LINK
#  Out-String
	[CmdletBinding(DefaultParameterSetName = 'T')]
	param(
		[Parameter(Mandatory, Position = 0)]
		[scriptblock]$Script
,
		[Parameter(ParameterSetName='S')]
		[string]$Separator
,
		[Parameter(ParameterSetName='T')]
		[string]$Terminator
,
		[ValidateNotNull()]
		[System.Text.StringBuilder]$Using
	)
	try {
		${function:take} = (New-Object System.Management.Automation.PSModuleInfo $true).NewBoundScriptBlock({
			if (0 -clt $script:state) { $script:acc.Append($script:sep) }
			foreach ($null in $args) { $script:acc.Append([string]$foreach.Current) }
			if (0 -ceq $script:state) { $script:acc.Append($script:sep) } else { $script:state = 1 }
		})
		& ${function:take}.Module {
			$script:acc, $script:sep, $script:state = $args
		}	$(if ($PSBoundParameters.ContainsKey('Using')) { $Using } else { [System.Text.StringBuilder]0 }) `
			$(if ($PSCmdlet.ParameterSetName -ceq 'S') { $Separator } else { $Terminator }) `
			(-($PSCmdlet.ParameterSetName -ceq 'S'))
	} catch {
		throw
	}
	$null = & $Script
	if (-not $PSBoundParameters.ContainsKey('Using')) {
		& ${function:take}.Module { $script:acc.ToString() }
	}
}
