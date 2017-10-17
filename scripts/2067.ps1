function Get-Field{
[CmdletBinding()]
	param ( 
		[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
		$InputObject,
		[Parameter(Position=1,Mandatory=$false)]
		[string]$Name,
		[switch]$Force,
		[switch]$AsHashtable
	)
	
	
	$publicNonPublic = [Reflection.BindingFlags]::Public -bor [Reflection.BindingFlags]::NonPublic
	$instance = $publicNonPublic -bor [Reflection.BindingFlags]::Instance
	$getField = $instance -bor [Reflection.BindingFlags]::GetField
	
	
	$type = $InputObject.gettype()
	$result = @()
	
	while ($type -ne [object] -and $type -ne [MarshalByRefObject] ) {
		$fields = $type.GetFields($instance)
		$result += $fields | Select-Object @{n="Name";e={$_.Name}},@{n="Value";e={$type.InvokeMember($_.Name, $getField, $null, $InputObject, $null)}}
		$type = $type.BaseType
		if (!$Force) { break; }
	}
	
	if (!$Name) { 
		if ($AsHashtable) {
			$hash = @{}
			$result | Foreach-Object {
				$hash[$_.Name] = $_.Value
			}
			return $hash
		}
		else {
			return $result
		}
	}
	$result | ForEach-Object { if ($_.Name -eq $Name) { $_.Value } }
}

New-Alias -Name gf -Value Get-Field -Force

