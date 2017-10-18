function Invoke-Generic {
#.Synopsis
#  Invoke Generic method definitions via reflection:
[CmdletBinding()]
param( 
   [Parameter(Position=0,Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
   [Alias('On','Type')]
   $InputObject
,
   [Parameter(Position=1,ValueFromPipelineByPropertyName=$true)]
   [Alias('Named')]
   [string]$MethodName
,
   [Parameter(Position=2)]
   [Alias('Returns')]
   [Type]$ReturnType
, 
   [Parameter(Position=3, ValueFromRemainingArguments=$true, ValueFromPipelineByPropertyName=$true)]
   [Object[]]$WithArgs
)
process {
   $Type = $InputObject -as [Type]
   if(!$Type) { $Type = $InputObject.GetType() }
   
   [Type[]]$ArgumentTypes = $withArgs | % { $_.GetType() }   
   [Object[]]$Arguments = $withArgs | %{ $_.PSObject.BaseObject }
   
   $Type.GetMethod($MethodName, $ArgumentTypes).MakeGenericMethod($returnType).Invoke( $on, $Arguments )
} }
