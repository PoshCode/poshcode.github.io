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
## ls | Select-Signed -NotMine -TrustedOnly | Set-AuthenticodeSignature
##    Re-sign scripts that are hash-correct but not signed by me or by someone trusted
##
####################################################################################################
## History:
## 1.6 - Converted to work with CTP 3, and added function help comments
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

####################################################################################################
function Get-UserCertificate {
<#.SYNOPSIS
 Gets the user's default signing certificate so we don't have to ask them over and over...
.DESCRIPTION
 The Get-UserCertificate function retrieves and returns a certificate from the user. It also stores 
 the certificate so it can bereused without re-querying for the location and/or password ... 
.RETURNVALUE
 An X509Certificate2 suitable for code-signing
###################################################################################################>
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
      $certs = ls cert:\CurrentUser\My
      if($certs.Count) {
         Write-Host "You have ${certs.Count} certs in your local cert storage which you can specify by Thumbprint:" -fore cyan
         $certs | Out-Host
      }
      $ExecutionContext.SessionState.Module.PrivateData = $(Read-Host "Please specify a user certificate")
   }
   if($ExecutionContext.SessionState.Module.PrivateData -isnot [System.Security.Cryptography.X509Certificates.X509Certificate2]) {
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
      $ExecutionContext.SessionState.Module.PrivateData = $Certificate
   }
   return $ExecutionContext.SessionState.Module.PrivateData
}
}

####################################################################################################
function Test-Signature {
<#.SYNOPSIS
 Tests a script signature to see if it is valid, or at least unaltered.
.DESCRIPTION
 The Test-Signature function processes the output of Get-AuthenticodeSignature to determine if it 
 is Valid, OR **unaltered** and signed by the user's certificate
.NOTES
 Test-Signature returns TRUE even if the root CA certificate can't be verified, as long as the 
 signing certificate's thumbnail matches the one specified by Get-UserCertificate.
.EXAMPLE
   ls *.ps1 | Get-AuthenticodeSignature | Where {Test-Signature $_}
 To get the signature reports for all the scripts that we consider safely signed.
.EXAMPLE
   ls | ? { gas $_ | test-signature }
 List all the valid signed scripts (or scripts signed by our cert)
.INPUTTYPE
  System.Management.Automation.Signature
.PARAMETER Signature
  Specifies the signature object to test. This should be the output of Get-AuthenticodeSignature.
.PARAMETER ForceValid
  Switch parameter, forces the signature to be valid (otherwise, even if the certificate chain can't be verified, we will accept the cert which matches the "user" certificate (see Get-UserCertificate).
  Aliases                      Valid
.RETURNVALUE
   Boolean value representing whether the script's signature is valid, or YOUR certificate
###################################################################################################>
[CmdletBinding()]
PARAM (
   [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
#  The signature to test.
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



####################################################################################################
function Set-AuthenticodeSignature {
<#.SYNOPSIS
   Adds an Authenticode signature to a Windows PowerShell script or other file.
.DESCRIPTION
   The Set-AuthenticodeSignature function adds an Authenticode signature to any file that supports Subject Interface Package (SIP).
 
   In a Windows PowerShell script file, the signature takes the form of a block of text that indicates the end of the instructions that are executed in the script. If there is a signature  in the file when this cmdlet runs, that signature is removed.
.NOTES
   After the certificate has been validated, but before a signature is added to the file, the function checks the value of the $SigningApproved preference variable. If this variable is not set, or has a value other than TRUE, you are prompted to confirm the signing of the script.
 
   When specifying multiple values for a parameter, use commas to separate the values. For example, "<parameter-name> <value1>, <value2>".
.EXAMPLE
   ls *.ps1 | Set-AuthenticodeSignature -Certificate $Certificate
   
   To sign all of the files with the specified certificate
.EXAMPLE
   ls *.ps1,*.psm1,*.psd1 | Get-AuthenticodeSignature | Where {!(Test-Signature $_ -Valid)} | gci | Set-AuthenticodeSignature

   List all the script files, and get and test their signatures, and then sign all of the ones that are not valid, using the user's default certificate.
.INPUTTYPE
   String. You can pipe a file path to Set-AuthenticodeSignature.
.PARAMETER FilePath
   Specifies the path to a file that is being signed.
   Aliases                      Path, FullName
.PARAMETER Certificate
   Specifies the certificate that will be used to sign the script or file. Enter a variable that stores an object representing the certificate or an expression that gets the certificate.
  
   To find a certificate, use Get-PfxCertificate or use the Get-ChildItem cmdlet in the Certificate (Cert:) drive. If the certificate is not valid or does not have code-signing authority, the command fails.
.RETURNVALUE
   System.Management.Automation.Signature
###################################################################################################>
[CmdletBinding()]
PARAM ( 
   [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName","Path")]
   [ValidateScript({ 
      if((resolve-path $_).Provider.Name -ne "FileSystem") {
         throw "Specified Path is not in the FileSystem: '$_'" 
      }
      if(!(Test-Path -PathType Leaf $_)) { 
         throw "Specified Path is not a File: '$_'" 
      }
      return $true
   })]
   [string[]]
   $FilePath
,  
   [Parameter(Position=2, Mandatory=$false)]
   $Certificate = $(Get-UserCertificate)
)

PROCESS {
   Write-Verbose "Set Authenticode Signature on $FilePath with $($Certificate | Out-String)"
   Microsoft.PowerShell.Security\Set-AuthenticodeSignature -Certificate $Certificate -FilePath $FilePath  
}
}
New-Alias sign Set-AuthenticodeSignature -EA "SilentlyContinue"

####################################################################################################
function Get-AuthenticodeSignature {
<#.SYNOPSIS
   Gets information about the Authenticode signature in a file.
.DESCRIPTION
   The Get-AuthenticodeSignature function gets information about the Authenticode signature in a file. If the file is not signed, the information is retrieved, but the fields are blank.
.NOTES
   For information about Authenticode signatures in Windows PowerShell, type "get-help About_Signing".

   When specifying multiple values for a parameter, use commas to separate the values. For example, "-<parameter-name> <value1>, <value2>".
.EXAMPLE
   Get-AuthenticodeSignature script.ps1
   
   To get the signature information about the script.ps1 script file.
.EXAMPLE
   ls *.ps1,*.psm1,*.psd1 | Get-AuthenticodeSignature
   
   Get the signature information for all the script and data files
.EXAMPLE
   ls *.ps1,*.psm1,*.psd1 | Get-AuthenticodeSignature | Where {!(Test-Signature $_ -Valid)} | gci | Set-AuthenticodeSignature

   This command gets information about the Authenticode signature in all of the script and module files, and tests the signatures, then signs all of the ones that are not valid.
.INPUTTYPE
   String. You can pipe the path to a file to Get-AuthenticodeSignature.
.PARAMETER FilePath
   The path to the file being examined. Wildcards are permitted, but they must lead to a single file. The parameter name ("-FilePath") is optional.
   Aliases                      Path, FullName
.RETURNVALUE
   System.Management.Automation.Signature
###################################################################################################>
[CmdletBinding()]
PARAM ( 
   [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName","Path")]
   [ValidateScript({ 
      if((resolve-path $_).Provider.Name -ne "FileSystem") {
         throw "Specified Path is not in the FileSystem: '$_'" 
      }
      if(!(Test-Path -PathType Leaf $_)) { 
         throw "Specified Path is not a File: '$_'" 
      }
      return $true
   })]
   [string[]]
   $FilePath
)

PROCESS {
   Microsoft.PowerShell.Security\Get-AuthenticodeSignature -FilePath $FilePath
}
}

####################################################################################################
function Select-Signed {
<#.SYNOPSIS
   Select files based on the status of their Authenticode Signature.
.DESCRIPTION
   The Select-Signed function filters files on the pipeline based on the state of their authenticode signature.
.NOTES
   For information about Authenticode signatures in Windows PowerShell, type "get-help About_Signing".

   When specifying multiple values for a parameter, use commas to separate the values. For example, "-<parameter-name> <value1>, <value2>".
.EXAMPLE
   ls *.ps1,*.ps[dm]1 | Select-Signed
   
   To get the signature information about the script.ps1 script file.
.EXAMPLE
   ls *.ps1,*.psm1,*.psd1 | Get-AuthenticodeSignature
   
   Get the signature information for all the script and data files
.EXAMPLE
   ls *.ps1,*.psm1,*.psd1 | Get-AuthenticodeSignature | Where {!(Test-Signature $_ -Valid)} | gci | Set-AuthenticodeSignature

   This command gets information about the Authenticode signature in all of the script and module files, and tests the signatures, then signs all of the ones that are not valid.
.INPUTTYPE
   String. You can pipe the path to a file to Get-AuthenticodeSignature.
.PARAMETER FilePath
   The path to the file being examined. Wildcards are permitted, but they must lead to a single file. The parameter name ("-FilePath") is optional.
   Aliases                      Path, FullName
.RETURNVALUE
   System.Management.Automation.Signature
###################################################################################################>
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
   [string[]]
   $FilePath
,
   [Parameter()]
   # Return only files that are signed with the users' certificate (as returned by Get-UserCertificate).
   [switch]$MineOnly
,
   [Parameter()]
   # Return only files that are NOT signed with the users' certificate (as returned by Get-UserCertificate).
   [switch]$NotMineOnly
,
   [Parameter()]
   [Alias("HashMismatch")]
   # Return only files with signatures that are broken (where the file has been edited, and the hash doesn't match).
   [switch]$BrokenOnly
,
   [Parameter()]
   # Returns the files that are Valid OR signed with the users' certificate (as returned by Get-UserCertificate).
   #
   # That is, TrustedOnly returns files returned by -ValidOnly OR -MineOnly (if you specify both parameters, you get only files that are BOTH -ValidOnly AND -MineOnly)
   [switch]$TrustedOnly
,
   [Parameter()]
   # Return only files that are "Valid": This means signed with any cert where the certificate chain is verifiable to a trusted root certificate.  This may or may not include files signed with the user's certificate.
   [switch]$ValidOnly
,
   [Parameter()]
   # Return only files that doesn't have a "Valid" signature, which includes files that aren't signed, or that have a hash mismatch, or are signed by untrusted certs (possibly including the user's certificate).
   [switch]$InvalidOnly
,
   [Parameter()]
   # Return only signable files that aren't signed at all. That is, only files that support Subject Interface Package (SIP) but aren't signed.
   [switch]$UnsignedOnly

)
PROCESS {
   if(!(Test-Path -PathType Leaf $FilePath)) { 
      # if($ErrorAction -ne "SilentlyContinue") {
      #    Write-Error "Specified Path is not a File: '$FilePath'"
      # }
   } else {

      foreach($sig in Get-AuthenticodeSignature -FilePath $FilePath) {
      
      # Broken only returns ONLY things which are HashMismatch
      if($BrokenOnly   -and $sig.Status -ne "HashMismatch") 
      { 
         Write-Debug "$($sig.Status) - Not Broken: $FilePath"
         return 
      }
      
      # Trusted only returns ONLY things which are Valid
      if($ValidOnly    -and $sig.Status -ne "Valid") 
      { 
         Write-Debug "$($sig.Status) - Not Trusted: $FilePath"
         return 
      }
      
      # AllValid returns only things that are SIGNED and not HashMismatch
      if($TrustedOnly  -and (($sig.Status -ne "HashMismatch") -or !$sig.SignerCertificate) ) 
      { 
         Write-Debug "$($sig.Status) - Not Valid: $FilePath"
         return 
      }
      
      # NOTValid returns only things that are SIGNED and Valid
      if($InvalidOnly  -and ($sig.Status -eq "Valid")) 
      { 
         Write-Debug "$($sig.Status) - Valid: $FilePath"
         return 
      }
      
      # Unsigned returns only things that aren't signed
      # NOTE: we don't test using NotSigned, because that's only set for .ps1 or .exe files??
      if($UnsignedOnly -and $sig.SignerCertificate ) 
      { 
         Write-Debug "$($sig.Status) - Signed: $FilePath"
         return 
      }
      
      # Mine returns only things that were signed by MY CertificateThumbprint
      if($MineOnly     -and (!($sig.SignerCertificate) -or ($sig.SignerCertificate.Thumbprint -ne $((Get-UserCertificate).Thumbprint))))
      {
         Write-Debug "Originally signed by someone else, thumbprint: $($sig.SignerCertificate.Thumbprint)"
         Write-Debug "Does not match your default certificate print: $((Get-UserCertificate).Thumbprint)"
         Write-Debug "     $FilePath"
         return 
      }

      # NotMine returns only things that were signed by MY CertificateThumbprint
      if($NotMineOnly  -and (!($sig.SignerCertificate) -or ($sig.SignerCertificate.Thumbprint -eq $((Get-UserCertificate).Thumbprint))))
      {
         if($sig.SignerCertificate) {
            Write-Debug "Originally signed by you, thumbprint: $($sig.SignerCertificate.Thumbprint)"
            Write-Debug "Matches your default certificate print: $((Get-UserCertificate).Thumbprint)"
            Write-Debug "     $FilePath"
         }
         return 
      }
      
      if(!$BrokenOnly  -and !$TrustedOnly -and !$ValidOnly -and !$InvalidOnly -and !$UnsignedOnly -and !($sig.SignerCertificate) ) 
      { 
         Write-Debug "$($sig.Status) - Not Signed: $FilePath"
         return 
      }
      
      get-childItem $sig.Path
   }}
}
}
Export-ModuleMember Set-AuthenticodeSignature, Get-AuthenticodeSignature, Test-Signature, Select-Signed, Get-UserCertificate


