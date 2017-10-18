#function Set-AttachedProperty {
[CmdletBinding()]
PARAM(
   [Parameter(Position=0,Mandatory=$true)
   [System.Windows.DependencyProperty]
   $Property
,
   [Parameter(Mandatory=$true,ValueFromPipeline=$true)
   $Element
)
DYNAMICPARAM {
   $paramDictionary = new-object System.Management.Automation.RuntimeDefinedParameterDictionary
   $Param1 = new-object System.Management.Automation.RuntimeDefinedParameter
   $Param1.Name = "Value"
   # $Param1.Attributes.Add( (New-ParameterAttribute -Position 1) )
   $Param1.Attributes.Add( (New-Object System.Management.Automation.ParameterAttribute -Property @{ Position = 1 }) )
   $Param1.ParameterType = $Property.PropertyType
           
   $paramDictionary.Add("Value", $Param1)
   
   return $paramDictionary
}
PROCESS {
   $Element.SetValue($Property, $Param1.Value)
   $Element
}
#}
#New-Alias sap Set-AttachedProperty

