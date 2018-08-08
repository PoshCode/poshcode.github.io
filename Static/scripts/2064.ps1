function Get-Field{
[CmdletBinding()]
	param ( 
		[Parameter(Position=0,Mandatory=$true)]
		$InputObject
	)
	
	
	$publicNonPublic = [Reflection.BindingFlags]::Public -bor [Reflection.BindingFlags]::NonPublic
	$instance = $publicNonPublic -bor [Reflection.BindingFlags]::Instance
	$getField = $instance -bor [Reflection.BindingFlags]::GetField
	
	
	$type = $InputObject.gettype()
	$result = @{}
	
	while ($type -ne [object] -and $type -ne [MarshalByRefObject] ) {
		$fields = $type.GetFields($instance)
		$fields | Foreach-Object { $result[$_.Name] =  $type.InvokeMember($_.Name, $getField, $null, $InputObject, $null) } 
		$type = $type.BaseType
	}
	
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
