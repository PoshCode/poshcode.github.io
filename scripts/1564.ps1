function getMyModulePrefix {
<#
	.SYNOPSIS
		An internal support routine for imported modules to retrieve a prefix
		assigned using the Import-Module -prefix argument.
	.DESCRIPTION
		Functions in modules imported with the -prefix option have two command
		names.  The module defined name and the prefixed name.  When calling one
		of these functions externally the prefixed name is required, when calling
		internally the defined name is required.
		
		Functions that have output that includes the functions name will return
		either the prefixed or non-prefixed depending on if it was internally or
		externally called which can cause confusion for the end user.
		
		For those times that your function needs to include the function name in
		some output use getMyModulePrefix then modify the function name before
		writing.
	.EXAMPLE
		$MyModulePrefix = "$(getMyModulePrefix)"
		$MyCommandName = $MyCommandName.replace("-","-$($MyModulePrefix)")
	.OUTPUT
		[string]
#>

   	[CmdletBinding()]
	param()
	
	$MyModuleName = "$($MyInvocation.MyCommand.ModuleName)"
	$MyCommandName = "$($MyInvocation.MyCommand.Name)"

	$MyModuleCommandName = (Get-Command -Module $MyModuleName -Name "*$($MyCommandName)" |
		where {$_.Name -ne $($MyCommandName)} | select -ExpandProperty Name )

	if ( $MyModuleCommandName -eq $null ) {
		$MyModulePrefix = $null
	} else {
		$MyModulePrefix = $MyModuleCommandName.replace("getMyModulePrefix", $null)
	}
	
	return $MyModulePrefix
}

