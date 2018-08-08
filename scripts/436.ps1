#requires -version 2.0
CMDLET Set-AuthenticodeSignature -snapin Huddled.BetterDefaults {
PARAM ( 
   [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName")]
   [ValidateScript({ 
      if((resolve-path .\breaking.ps1).Provider.Name -ne "FileSystem") {
         throw "Specified Path is not in the FileSystem: '$_'" 
      }
      if(!(Test-Path -PathType Leaf $_)) { 
         throw "Specified Path is not a File: '$_'" 
      }
      return $true
   })]
   [string]
   $Path
, 
   $Certificate=$(ls cert:\CurrentUser\my\0DA3A2A2189CD74AE371E6C57504FEB9A59BB22E)
)
   Microsoft.PowerShell.Security\Set-AuthenticodeSignature -Certificate $Certificate -FilePath $Path  
}

CMDLET Get-AuthenticodeSignature -snapin Huddled.BetterDefaults {
PARAM ( 
   [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName")]
   [ValidateScript({ 
      if((resolve-path .\breaking.ps1).Provider.Name -ne "FileSystem") {
         throw "Specified Path is not in the FileSystem: '$_'" 
      }
      if(!(Test-Path -PathType Leaf $_)) { 
         throw "Specified Path is not a File: '$_'" 
      }
      return $true
   })]
   [string]
   $Path
)
   Microsoft.PowerShell.Security\Get-AuthenticodeSignature -FilePath $Path  
}

Export-ModuleMember Set-AuthenticodeSignature,Get-AuthenticodeSignature

