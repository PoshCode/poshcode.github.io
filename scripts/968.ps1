#Steven Murawski
#http://blog.usepowershell.com
#03/20/2009

#Examples:
# get-staticmethoddefinition max math
# [math] | get-staticmethoddefinition max

function Get-StaticMethodDefinition()
{
	param ([string[]]$Method, [Type]$Type=$null)
	BEGIN
	{
		if ($Type -ne $null)
		{
			$Type | Get-StaticMethodDefinition $Method
		}
	}
	
	PROCESS
	{
		if ($_ -ne $null)
		{
			$_ | Get-Member -Name $Method -Static -MemberType Method | ForEach-Object {$_.Definition -replace '\), ', "), `n"}
		}
	}
}
