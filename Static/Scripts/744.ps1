# Find all files which does not contains the text in $Pattern
function ssHasNot(
[string] $Path="*.txt"
,[string] $pattern=""
)
{
	$has=[string]@(get-childitem $path | ss $pattern | foreach {$_.Path})	
	get-childitem $path| where {$has.Contains($_.FullName) -eq $false}
}

