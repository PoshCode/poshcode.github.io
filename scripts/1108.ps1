## CHANGE this to point to your WatiN.Core.dll
$WatinPath = Convert-Path (Resolve-Path "$(Split-Path $Profile)\Libraries\Watin2\WatiN.Core.dll")
## Load the assembly
$global:watin = [Reflection.Assembly]::LoadFrom( $WatinPath )

## initialize the global "Find" functions ...
Function Start-Watin {
Param([WatiN.Core.IE]$ie)
   if(!(Get-Command Find-Link -EA0)) {
      ## Generate Find-Button, Find-TextField, etc:
      $ie | Get-Member -Type Method |
         Where-Object {
            $type = $_.Definition.Split(" ")[0]
            [WatiN.Core.Element].IsAssignableFrom( ([type]$type) )
         } | 
         ForEach-Object {
            New-Item -Path "Function:global:Find-$($_.Name)" -Value $( iex @"
{
Param(`$Attribute, [regex]`$value)
`$ie.$($_.Name)( ([Watin.Core.Find]::By( `$Attribute, `$value)) )
}
"@          )
         }
   }
}

Function New-Watin {
PARAM($URL = "http://www.google.com")
   ## Create an initial window (I'm creating IE, but WatiN handles Firefox too)
   $global:ie = new-object WatiN.Core.IE $URL
   Start-Watin $ie
}

Function Get-Watin {
PARAM($URL = "http://www.google.com")
   ## Find an existing window (I'm using IE, but WatiN handles Firefox too)
   $global:ie = [WatiN.Core.IE]::InternetExplorers()[0]
   Start-Watin $ie
   Set-WatinUrl $url
}

function Set-WatinUrl {
   Param($url) 
   $IE.Goto( $url )
}

