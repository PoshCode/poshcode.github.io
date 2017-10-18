
function Select-CLSCompliant {
#.Synopsis
#  Outputs the same as "Select-Object *" with basic error handling for properties that are not CLS Compliant

[CmdletBinding()]
param([Parameter(ValueFromPipeline=$true)]$InputObject)
process {
   foreach($in in $InputObject) {
      $In | Select-Object *

      trap [System.Management.Automation.ExtendedTypeSystemException] {
         $m = $_.Exception.Message
         $matches = [regex]::Matches($m, 'The field/property: \"(?<field>.*)\" for type: \"(?<Type>[^"]+)\" .* Failed to use non CLS compliant type.')
         $type = $matches[0].Groups["Type"].Value -as [Type]
         
            
         $properties = $type.GetProperties()
         $output = @{}
         $properties | %{ $Output.($_.Name) = $_.GetValue( $In, $null ) }
         new-Object PSObject -Property $Output
         continue
      }
   }
}}
