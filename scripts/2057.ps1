function Get-Field{
[CmdletBinding()]
	param ( 
		[Parameter(Position=0,Mandatory=$true)]
		$InputObject
	)
	
	$type = $InputObject.gettype()
	
	$publicNonPublic = [Reflection.BindingFlags]::Public -bor [Reflection.BindingFlags]::NonPublic
	$instance = $publicNonPublic -bor [Reflection.BindingFlags]::Instance
	$getField = $instance -bor [Reflection.BindingFlags]::GetField
	
	$fields = $type.GetFields($instance)
	
	$result = @{}
	$fields | Foreach-Object { $result[$_.Name] =  $type.InvokeMember($_.Name, $getField, $null, $InputObject, $null) } 
	
	$result
	
}

##Example:
##$context = (Get-Field $ExecutionContext)._context
##$context
##Get-Field $context
##$sessionState = (Get-Field $context)._enginesessionstate
##$sessionState
##$moduleTable = (Get-Field $sessionState)._moduleTable
##$moduleTable

