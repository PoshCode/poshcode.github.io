
function Get-Parameters {
	param([string]$CommandName, [switch]$IncludeCommon)
	
	try {
		$command = get-command $commandname
		$parameters = (new-object System.Management.Automation.CommandMetaData $command, $includecommon).Parameters
	         $parameters.getenumerator() # unroll dictionary
         } catch {
		write-warning "Could not find command or obtain parameters for $commandname"
         }
}


