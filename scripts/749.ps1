#Requires -version 2.0
## Authenticode.psm1 updated for CTP 3
####################################################################################################
## Wrappers for the Get-AuthenticodeSignature and Set-AuthenticodeSignature cmdlets 
## These properly parse paths, so they don't kill your pipeline and script if you include a folder 
##
## Usage:
## ls | Get-AuthenticodeSignature
##    Get all the signatures
##
## ls | Select-Signed -Mine -Broken | Set-AuthenticodeSignature
##    Re-sign anything you signed before that has changed
##
## ls | Select-Signed -NotMine -ValidOnly | Set-AuthenticodeSignature
##    Re-sign scripts that are hash-correct but not signed by me or by someone trusted
##
####################################################################################################
## History:
## 1.5 - Moved the default certificate setting into the module info Authenticode.psd1 file
##       Note: If you get this off PoshCode, you'll have to create it yourself, see below:
## 1.4 - Moved the default certificate setting into an external psd1 file.
## 1.3 - Fixed some bugs in If-Signed and renamed it to Select-Signed
##     - Added -MineOnly and -NotMineOnly switches to Select-Signed
## 1.2 - Added a hack workaround to make it appear as though we can sign and check PSM1 files
##       It's important to remember that the signatures are NOT checked by PowerShell yet...
## 1.1 - Added a filter "If-Signed" that can be used like: ls | If-Signed
##     - With optional switches: ValidOnly, InvalidOnly, BrokenOnly, TrustedOnly, UnsignedOnly
##     - commented out the default Certificate which won't work for "you"
## 1.0 - first working version, includes wrappers for Get and Set
##
####################################################################################################
## README! README! README! README! #################################################################
## README! README! README! README! #################################################################
##
## You should set the location to your default signing certificate. The permanent way to do that is
## to modify (or create) the .psd1 file to set the PrivateData member variable. Otherwise you'll be 
## prompted to provide a cert path whenever you try to sign a script without passing a certificate.
##
## The PrivateData variable should point at your code-signing certificate either with a full path
## or with the THUMBPRINT of a certificate you have available in your Cert:\CurrentUser\My\ provider
##
## EG:
##      F05F583BB5EA4C90E3B9BF1BDD0B657701245BD5 
## OR:
##      "Cert:\CurrentUser\My\F05F583BB5EA4C90E3B9BF1BDD0B657701245BD5"
## OR a file name:
##      "C:\Users\Joel\Documents\WindowsPowerShell\PoshCerts\Joel-Bennett_Code-Signing.pfx"
##
## The simplest thing is to just create a new PSD1
##
##    New-ModuleManifest .\Authenticode.psd1 -Nested .\Authenticode.psm1 `
##    -Author "" -COmpany "" -Copy "" -Desc "" `
##    -Types @() -Formats @() -RequiredMod @() -RequiredAs @() -Other @() `
##    -PrivateData F05F583BB5EA4C90E3B9BF1BDD0B657701245BD5
##
####################################################################################################

function Get-UserCertificate {
[CmdletBinding()]
PARAM ()
PROCESS {
   trap {
      Write-Host "The authenticode script module requires configuration to function fully!"
      Write-Host
      Write-Host "You must put the path to your default signing certificate in the module metadata"`
                 "file before you can use the module's Set-Authenticode cmdlet or to the 'mine'"`
                 "feature of the Select-Signed or Test-Signature. To set it up, you can do this:"
      Write-Host 
      Write-Host "PrivateData = 'C:\Users\${Env:UserName}\Documents\WindowsPowerShell\PoshCerts\Code-Signing.pfx'"
      Write-Host
      Write-Host "If you load your certificate into your 'CurrentUser\My' store, or put the .pfx file"`
                 "into the folder with the Authenthenticode module script, you can just specify it's"`
                 "thumprint or filename, respectively. Otherwise, it should be a full path."
      Write-Error $_
      return      
   }
   # Import-LocalizedData -bindingVariable CertificatePath -EA "STOP"
   if(!$ExecutionContext.SessionState.Module.PrivateData) {
      $ExecutionContext.SessionState.Module.PrivateData = $(Read-Host "Please specify a user certificate")
   }
   # Write-Host "CertificatePath: $ExecutionContext.SessionState.Module.PrivateData" -fore cyan
   $ResolvedPath = $Null
   $ResolvedPath = Resolve-Path $ExecutionContext.SessionState.Module.PrivateData -ErrorAction "SilentlyContinue"
   if(!$ResolvedPath -or !(Test-Path $ResolvedPath -ErrorAction "SilentlyContinue")) {
      # Write-Host "ResolvedPath: $ResolvedPath" -fore green
      $ResolvedPath = Resolve-Path (Join-Path $PsScriptRoot $ExecutionContext.SessionState.Module.PrivateData -ErrorAction "SilentlyContinue") -ErrorAction "SilentlyContinue" 
   }
   if(!$ResolvedPath -or !(Test-Path $ResolvedPath -ErrorAction "SilentlyContinue")) {
      # Write-Host "ResolvedPath: $ResolvedPath" -fore yellow
      $ResolvedPath = Resolve-Path (Join-Path "Cert:\CurrentUser\My" $ExecutionContext.SessionState.Module.PrivateData -ErrorAction "SilentlyContinue") -ErrorAction "SilentlyContinue" 
   }

   $Certificate = get-item $ResolvedPath -ErrorAction "SilentlyContinue"
   if($Certificate -is [System.IO.FileInfo]) {
      $Certificate = Get-PfxCertificate $Certificate -ErrorAction "SilentlyContinue"
   }
   Write-Verbose "Certificate: $($Certificate | Out-String)"
   return $Certificate
}
}

function Test-Signature {
[CmdletBinding()]
PARAM (
   [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
#  We can't actually require the type, or we won't be able to check the fake ones
#   [System.Management.Automation.Signature]
   $Signature
,
   [Alias("Valid")]
   [Switch]$ForceValid
)

return ( $Signature.Status -eq "Valid" -or 
      ( !$ForceValid -and 
         ($Signature.Status -eq "UnknownError") -and 
         ($_.SignerCertificate.Thumbprint -eq $(Get-UserCertificate).Thumbprint) 
      ) )
}

function Set-AuthenticodeSignature{
[CmdletBinding()]
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
   [Parameter(Position=2, Mandatory=$false)]
   $Certificate = $(Get-UserCertificate)
)

PROCESS {
   Write-Verbose "Set Authenticode Signature on $Path with $($Certificate | Out-String)"
   Microsoft.PowerShell.Security\Set-AuthenticodeSignature -Certificate $Certificate -FilePath $Path  
}
}

New-Alias sign Set-AuthenticodeSignature

function Get-AuthenticodeSignature {
[CmdletBinding()]
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

PROCESS {
   Microsoft.PowerShell.Security\Get-AuthenticodeSignature -FilePath $Path
}
}

function Select-Signed {
[CmdletBinding()]
PARAM ( 
   [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName")]
   [ValidateScript({ 
      if((resolve-path $_).Provider.Name -ne "FileSystem") {
         throw "Specified Path is not in the FileSystem: '$_'" 
      }
      return $true
   })]
   [string]
   $Path
,
   [Parameter()]
   [switch]$MineOnly
,
   [Parameter()]
   [switch]$NotMineOnly
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

   if(!(Test-Path -PathType Leaf $Path)) { 
      # if($ErrorAction -ne "SilentlyContinue") {
      #    Write-Error "Specified Path is not a File: '$Path'"
      # }
   } else {

      $sig = Get-AuthenticodeSignature $Path 
      
      # Broken only returns ONLY things which are HashMismatch
      if($BrokenOnly   -and $sig.Status -ne "HashMismatch") 
      { 
         Write-Debug "$($sig.Status) - Not Broken: $Path"
         return 
      }
      
      # Trusted only returns ONLY things which are Valid
      if($TrustedOnly  -and $sig.Status -ne "Valid") 
      { 
         Write-Debug "$($sig.Status) - Not Trusted: $Path"
         return 
      }
      
      # AllValid returns only things that are SIGNED and not HashMismatch
      if($ValidOnly    -and (($sig.Status -ne "HashMismatch") -or !$sig.SignerCertificate) ) 
      { 
         Write-Debug "$($sig.Status) - Not Valid: $Path"
         return 
      }
      
      # NOTValid returns only things that are SIGNED and not HashMismatch
      if($InvalidOnly  -and ($sig.Status -eq "Valid")) 
      { 
         Write-Debug "$($sig.Status) - Valid: $Path"
         return 
      }
      
      # Unsigned returns only things that aren't signed
      # NOTE: we don't test using NotSigned, because that's only set for .ps1 or .exe files??
      if($UnsignedOnly -and $sig.SignerCertificate ) 
      { 
         Write-Debug "$($sig.Status) - Signed: $Path"
         return 
      }
      
      # Mine returns only things that were signed by MY CertificateThumbprint
      if($MineOnly     -and (!($sig.SignerCertificate) -or ($sig.SignerCertificate.Thumbprint -ne $((Get-UserCertificate).Thumbprint))))
      {
         Write-Debug "Originally signed by someone else, thumbprint: $($sig.SignerCertificate.Thumbprint)"
         Write-Debug "Does not match your default certificate print: $((Get-UserCertificate).Thumbprint)"
         Write-Debug "     $Path"
         return 
      }

      # NotMine returns only things that were signed by MY CertificateThumbprint
      if($NotMineOnly  -and (!($sig.SignerCertificate) -or ($sig.SignerCertificate.Thumbprint -eq $((Get-UserCertificate).Thumbprint))))
      {
         if($sig.SignerCertificate) {
            Write-Debug "Originally signed by you, thumbprint: $($sig.SignerCertificate.Thumbprint)"
            Write-Debug "Matches your default certificate print: $((Get-UserCertificate).Thumbprint)"
            Write-Debug "     $Path"
         }
         return 
      }
      
      if(!$BrokenOnly  -and !$TrustedOnly -and !$ValidOnly -and !$InvalidOnly -and !$UnsignedOnly -and !($sig.SignerCertificate) ) 
      { 
         Write-Debug "$($sig.Status) - Not Signed: $Path"
         return 
      }
      
      get-childItem $sig.Path
   }
}
Export-ModuleMember Set-AuthenticodeSignature, Get-AuthenticodeSignature, Test-Signature, Select-Signed, Get-UserCertificate

