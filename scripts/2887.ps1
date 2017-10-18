function Get-ScriptDirectory {   
	$invocation = (Get-Variable MyInvocation -Scope 1).Value
	$script = [IO.FileInfo] $invocation.MyCommand.Path
	if ([IO.File]::Exists($script)) {
    	Return (Split-Path $script.Fullname)
	} else {
		return $null
	}
}
