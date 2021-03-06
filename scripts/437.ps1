#Requires -version 2.0
## Authenticode.psm1
####################################################################################################
## Wrappers for the Get-AuthenticodeSignature and Set-AuthenticodeSignature cmdlets 
## These properly parse paths, so they don't kill your pipeline and script if you include a folder 
##
## Usage:
## ls | Get-AuthenticodeSignature
## ls | If-Signed -Broken | Set-AuthenticodeSignature Get-PfxCertificate C:\My.pfx
####################################################################################################
## History:
## 1.1 - Added a filter "If-Signed" that can be used like: ls | If-Signed
##     - With optional switches: ValidOnly, InvalidOnly, BrokenOnly, TrustedOnly, UnsignedOnly
##     - commented out the default Certificate which won't work for "you"
## 1.0 - first working version, includes wrappers for Get and Set
##
CMDLET Set-AuthenticodeSignature -snapin Huddled.BetterDefaults {
PARAM ( 
   [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName")]
   [ValidateScript({ 
      if((resolve-path $_).Provider.Name -ne "FileSystem") {
         throw "Specified Path is not in the FileSystem: '$_'" 
      }
      if(!(Test-Path -PathType Leaf $_)) { 
         throw "Specified Path is not a File: '$_'" 
      }
      return $true
   })]
   [string]
   $Path
,  ## TODO: you should CHANGE THIS to a method which gets *your* default certificate
   $Certificate # = $(ls cert:\CurrentUser\my\0DA3A2A2189CD74AE371E6C57504FEB9A59BB22E)
)
   Microsoft.PowerShell.Security\Set-AuthenticodeSignature -Certificate $Certificate -FilePath $Path  
}

CMDLET Get-AuthenticodeSignature -snapin Huddled.BetterDefaults {
PARAM ( 
   [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName")]
   [ValidateScript({ 
      if((resolve-path $_).Provider.Name -ne "FileSystem") {
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


CMDLET If-Signed -snapin Huddled.BetterDefaults {
PARAM ( 
   [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName")]
   [ValidateScript({ 
      if((resolve-path $_).Provider.Name -ne "FileSystem") {
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
   [Parameter()]
   [switch]$BrokenOnly
,
   [Parameter()]
   [switch]$TrustedOnly
,
   [Parameter()]
   [switch]$ValidOnly
,
   [Parameter()]
   [switch]$InvalidOnly
,
   [Parameter()]
   [switch]$UnsignedOnly
)
   $sig = Microsoft.PowerShell.Security\Get-AuthenticodeSignature -FilePath $Path 
   
   # Broken only returns ONLY things which are HashMismatch
   if($BrokenOnly  -and $sig.Status -ne "HashMismatch") 
   { 
      Write-Debug "$($sig.Status) - Not Broken: $Path"
      return 
   }
   # Trusted only returns ONLY things which are Valid
   if($TrustedOnly -and $sig.Status -ne "Valid") 
   { 
      Write-Debug "$($sig.Status) - Not Trusted: $Path"
      return 
   }
   
   # AllValid returns only things that are SIGNED and not HashMismatch
   if($ValidOnly   -and (($sig.Status -ne "HashMismatch") -or !$_.SignerCertificate) ) 
   { 
      Write-Debug "$($sig.Status) - Not Valid: $Path"
      return 
   }
   
   # NOTValid returns only things that are SIGNED and not HashMismatch
   if($InvalidOnly    -and ($sig.Status -eq "Valid")) 
   { 
      Write-Debug "$($sig.Status) - Valid: $Path"
      return 
   }
   
   # Unsigned returns only things that aren't signed
   # NOTE: we don't test using NotSigned, because that's only set for .ps1 or .exe files??
   if($UnsignedOnly    -and $_.SignerCertificate ) 
   { 
      Write-Debug "$($sig.Status) - Signed: $Path"
      return 
   }
   
   if(!$BrokenOnly -and !$TrustedOnly -and !$ValidOnly -and !$InvalidOnly -and !$UnsignedOnly -and !$_.SignerCertificate ) 
   { 
      Write-Debug "$($sig.Status) - Not Signed: $Path"
      return 
   }
   
   get-childItem $sig.Path
}


Export-ModuleMember Set-AuthenticodeSignature,Get-AuthenticodeSignature,If-Signed

