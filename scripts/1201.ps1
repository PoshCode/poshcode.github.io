# Eg: Get-Constructor System.IO.StreamReader

function Get-Constructor {
Param([Type]$type) 

$OFS = ", "

$Type.GetConstructors("Public,Instance,Static") | 
  ForEach-Object { "{0}( {1} )" -f $_.DeclaringType, "$($_.GetParameters() | %{ $_.ParameterType })" }

}
