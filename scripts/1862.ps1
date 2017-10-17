function Get-Constructor {
PARAM( [Type]$type, [Switch]$Simple)
   if($Simple) {
   $type.GetConstructors() | 
      Select @{
         l="$($type.Name) Constructor"
         e={ "New-Object $($type.FullName) $(($_.GetParameters() | ForEach { "[{0}]`${1}" -f $_.ParameterType.FullName, $_.Name }) -Join ", ")" }
      }
   } else {
   $type.GetConstructors() | 
      Select @{
         name = "$($type.Name) Constructors"
         expression = { 
            $parameters = $(
               foreach($param in $_.GetParameters()) {
                  Write-Host $param.ParameterType.FullName.TrimEnd('&'), $param.Name -fore cyan
                  
                  if($param.ParameterType.Name.EndsWith('&')) { $ref = '[ref]' } else { $ref = '' }
                  if($param.ParameterType.IsArray) { $array = ',' } else { $array = '' }
                  '{0}({1}[{2}]${3})' -f $ref, $array, $param.ParameterType.FullName.TrimEnd('&'), $param.Name
               }
            )
         
            "New-Object $($type.FullName) $($parameters -join ', ')"
         }
      }
   }
}

Set-Alias gctor Get-Constructor
