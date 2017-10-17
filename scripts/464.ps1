#Requires -version 2.0
## Authenticode.psm1
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
## YOU MUST set the location to your default signing certificate, by either modifiying this script, 
## or by creating a language resource file! The second is easier: For english, create a subdirectory 
## next to this file called 'en' (for English) and in that folder, create a 'Authenticode.psd1' file 
## EG: Set-Content .\en\Authenticode.psd1 $CertificatePath
## Basically, the file should contain the path to your code-signing certificate, preferably from the
## CERT:\ PsProvider, but alternately, from a PFX file...
## EG:
##      "Cert:\CurrentUser\My\F05F583BB5EA4C90E3B9BF1BDD0B657701245BD5"
## OR:
##      "C:\Users\Joel\Documents\WindowsPowerShell\PoshCerts\Joel-Bennett_Code-Signing.pfx"
## See: http://huddledmasses.org/misusing-powershell-localizable-data/
####################################################################################################

CMDLET Get-UserCertificate -snapin Huddled.Authenticode {
   trap {
      Write-Host "The authenticode script module requires a configuration file to function fully!"
      Write-Host
      Write-Host "You must put the path to your default signing certificate in the configuration"`
                 "file before you can use the module's Set-Authenticode cmdlet or to the 'mine'"`
                 "feature of the Select-Signed or Test-Signature. To set it up, you can do this:"
      Write-Host 
      Write-Host "MkDir $(Join-Path $PsScriptRoot $(Get-Culture)) |"
      Write-Host "   Join-Path -Path {`$_} 'Authenticode.psd1'    |"
      Write-Host "   New-Item  -Path {`$_} -Type File -Value '`"ThePathToYourCertificate`"'"
      Write-Host
      Write-Host "If you load your certificate into your 'CurrentUser\My' store, or put the .pfx file"`
                 "into the folder with the Authenthenticode module script, you can just specify it's"`
                 "thumprint or filename, respectively. Otherwise, it should be a full path."
      return
   }   
   Import-LocalizedData -bindingVariable CertificatePath -EA "STOP"
   
   $ResolvedPath = $Null
   $ResolvedPath = Resolve-Path $CertificatePath -ErrorAction "SilentlyContinue"
   if(!$ResolvedPath) { 
      $ResolvedPath = Resolve-Path (Join-Path $PsScriptRoot $CertificatePath -ErrorAction "SilentlyContinue") -ErrorAction "SilentlyContinue" 
   }
   if(!$ResolvedPath) { 
      $ResolvedPath = Resolve-Path (Join-Path "Cert:\CurrentUser\My" $CertificatePath -ErrorAction "SilentlyContinue") -ErrorAction "SilentlyContinue" 
   }

   $Certificate = get-item $ResolvedPath -ErrorAction "SilentlyContinue"
   if($Certificate -is [System.IO.FileInfo]) {
      $Certificate = Get-PfxCertificate $Certificate -ErrorAction "SilentlyContinue"
   }
   return $Certificate
}

$DefaultCertificate = Get-UserCertificate
$CertificateThumbprint = $DefaultCertificate.Thumbprint


CMDLET Test-Signature -snapin Huddled.Authenticode {
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
         ($_.SignerCertificate.Thumbprint -eq $CertificateThumbprint) 
      ) )
}

CMDLET Set-AuthenticodeSignature -snapin Huddled.Authenticode {
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
   $Certificate = $DefaultCertificate
)

PROCESS {
   if( ".psm1" -eq [IO.Path]::GetExtension($Path) ) {
   # function setpsm1sig($Path) {
      $ps1Path = "$Path.ps1"
      Rename-Item $Path (Split-Path $ps1Path -Leaf)
      $sig = Microsoft.PowerShell.Security\Set-AuthenticodeSignature -Certificate $Certificate -FilePath $ps1Path | Select *
      Rename-Item $ps1Path (Split-Path $Path -Leaf) 
      $sig.PSObject.TypeNames.Insert( 0, "System.Management.Automation.Signature" )
      $sig.Path = $Path
      $sig
   } else {
      Microsoft.PowerShell.Security\Set-AuthenticodeSignature -Certificate $Certificate -FilePath $Path  
   }
}
}

CMDLET Get-AuthenticodeSignature -snapin Huddled.Authenticode {
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
   if( ".psm1" -eq [IO.Path]::GetExtension($Path) ) {
   # function getpsm1sig($Path) {
      $ps1Path = "$Path.ps1"
      Rename-Item $Path (Split-Path $ps1Path -Leaf)
      $sig = Microsoft.PowerShell.Security\Get-AuthenticodeSignature -FilePath $ps1Path | select *
      Rename-Item $ps1Path (Split-Path $Path -Leaf) 
      $sig.PSObject.TypeNames.Insert( 0, "System.Management.Automation.Signature" )
      $sig.Path = $Path
      $sig
   } else {
      Microsoft.PowerShell.Security\Get-AuthenticodeSignature -FilePath $Path
   }

}
}

CMDLET Select-Signed -snapin Huddled.Authenticode {
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
      if($MineOnly     -and (!($sig.SignerCertificate) -or ($sig.SignerCertificate.Thumbprint -ne $CertificateThumbprint)))
      {
         Write-Debug "Originally signed by someone else, thumbprint: $($sig.SignerCertificate.Thumbprint)"
         Write-Debug "Does not match your default certificate print: $CertificateThumbprint"
         Write-Debug "     $Path"
         return 
      }

      # NotMine returns only things that were signed by MY CertificateThumbprint
      if($NotMineOnly  -and (!($sig.SignerCertificate) -or ($sig.SignerCertificate.Thumbprint -eq $CertificateThumbprint)))
      {
         if($sig.SignerCertificate) {
            Write-Debug "Originally signed by you, thumbprint: $($sig.SignerCertificate.Thumbprint)"
            Write-Debug "Matches your default certificate print: $CertificateThumbprint"
            Write-Debug "     $Path"
         }
         return 
      }
      
      if(!$BrokenOnly  -and !$TrustedOnly -and !$ValidOnly -and !$InvalidOnly -and !$UnsignedOnly -and !($sig.SignerCertificate) ) 
      { 
         # Write-Debug ("You asked for Broken ({0}) or Trusted ({1}) or Valid ({2}) or Invalid ({3}) or Unsigned ({4}) and the cert is: ({5})" -f  [int]$BrokenOnly, [int]$TrustedOnly, [int]$ValidOnly, [int]$InvalidOnly, [int]$UnsignedOnly, $sig.SignerCertificate)
         Write-Debug "$($sig.Status) - Not Signed: $Path"
         return 
      }
      
      get-childItem $sig.Path
   }
}

Export-ModuleMember Set-AuthenticodeSignature,Get-AuthenticodeSignature,Test-Signature,Select-Signed,Get-UserCertificate

# SIG # Begin signature block
# MIIK0AYJKoZIhvcNAQcCoIIKwTCCCr0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUHoNib4Y35ha7fCzaYIyjS3sJ
# HWGgggbEMIIGwDCCBKigAwIBAgIJAKpDRVMtv0LqMA0GCSqGSIb3DQEBBQUAMIHG
# MQswCQYDVQQGEwJVUzERMA8GA1UECBMITmV3IFlvcmsxEjAQBgNVBAcTCVJvY2hl
# c3RlcjEaMBgGA1UEChMRSHVkZGxlZE1hc3Nlcy5vcmcxHjAcBgNVBAsTFUNlcnRp
# ZmljYXRlIEF1dGhvcml0eTErMCkGA1UEAxMiSm9lbCBCZW5uZXR0IENlcnRpZmlj
# YXRlIEF1dGhvcml0eTEnMCUGCSqGSIb3DQEJARYYSmF5a3VsQEh1ZGRsZWRNYXNz
# ZXMub3JnMB4XDTA4MDcwMjAzNTA1OVoXDTA5MDcwMjAzNTA1OVowgcAxCzAJBgNV
# BAYTAlVTMREwDwYDVQQIEwhOZXcgWW9yazESMBAGA1UEBxMJUm9jaGVzdGVyMRow
# GAYDVQQKExFIdWRkbGVkTWFzc2VzLm9yZzEuMCwGA1UECxMlaHR0cDovL0h1ZGRs
# ZWRNYXNzZXMub3JnL0NvZGVDZXJ0LmNydDEVMBMGA1UEAxMMSm9lbCBCZW5uZXR0
# MScwJQYJKoZIhvcNAQkBFhhKYXlrdWxASHVkZGxlZE1hc3Nlcy5vcmcwggIiMA0G
# CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDXuceXJZYARJbSTU4hoh91goVp2POx
# 6Mz/QZ6D5jcT/JNhdW2GwYQ9YUxNj8jkhXg2Ixbgb1djRGMFC/ekgRkgLxyiuhRh
# NrVE1IdV4hT4as3idqnvWOi0S3z2R2EGdebqwm2mrRmq9+DbY+FGxuNwLboWZx8Z
# roGlLLHRPzt9pabQq/Nu/FIFO+4JzZ8S5ZnEaKTm4dpD0g6j653OWYVvNXJbS/W4
# Dis5aRkHT1q1Gp02dYHh3NTKrpv1nus9BTDlJRwmU/FgGLNQIvnRwqVoBh+I7tVq
# NIRnI1RpDTGyFEohbH8mRlwq3z4ijtb6j9boUJEqd8hQshzUMcALoTIR1tN/5APX
# u2j4OqGFESM/OG0i2hLKbnP81u581aZT1BfVfQxvDuWrFiurMxllVGY1NvKkXwc8
# aOZktqMQWbWAs2bxZqERbOILXOmkL/mvPdy+e5yQveriHAhrDONu7a79ylreMHBR
# XrmYJTK2G/aHvB5vrXjMPw0TBeph0sM2BN2eVzenAAMsIiGlXPXvtKrpKRiBdx5f
# 9SV5dyUG2tR8ANDuc2AMB8FKICuMUd8Sx96p4FOBQhXhvF/RZcWZIW5o+A4sHvYE
# /s4oiX7LxGrQK2abNiCVs9BDLI/EcSs/TP+ZskBqu7Qb+AVeevoY3T7skihuyC/l
# h7EwqjfNpVQ9UwIDAQABo4G0MIGxMB0GA1UdDgQWBBTgB9XYJV/kJAvnkWmKDHsh
# 7Cn3PzAfBgNVHSMEGDAWgBQ+5x4ah0JG0o4iUj0TebNd4MCVxTAJBgNVHRMEAjAA
# MBEGCWCGSAGG+EIBAQQEAwIEEDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDAzALBgNV
# HQ8EBAMCBsAwLAYJYIZIAYb4QgENBB8WHU9wZW5TU0wgR2VuZXJhdGVkIENlcnRp
# ZmljYXRlMA0GCSqGSIb3DQEBBQUAA4ICAQAw8B6+s48CZZo5h5tUeKV7OWNXKRG7
# xkyavMkXpEi58BSLutmE3O7smc3uvu3TdCXENNUlGrcq/KQ8y2eEI8QkHgT99VgX
# r+v5xu2KnJXiOOIxi65EZybRFFFaGJNodTcrK8L/tY6QLF02ilOlEgfcc1sV/Sj/
# r60JS1iXIMth7nYZVjtWeYXOrsd+I+XwJuoVNJlELNdApOU4ZVNrPEuV+QRNMimj
# lqIOv2tn9TDdNGUqaOCI0w+a1XQvapEPWETfQK+o9pvYINTswGDjNeb7Xz8ar2JB
# 9IVs2xtxDohHB75kyRrlY1hkoY5j12ZhWOlm0L9Ks6XvmMtXJIjj0/m9Z+3s+9p6
# U7IYjz5NnzmDvtNUn2y9zxB/rUx/JqoUO3BWRKiLX0lvGRWJlzFr9978kH2SXxAD
# rsKfzB7YZzMh9hZkGNlJf4T+HTB/OXG1jyfkyqQvhNB/tDAaq+ejDtKNBF4hMS7K
# Z0B4vagIxFwMuTiei4UaOjrGzeCfT9w1Bmj6uLJme5ydQVM0V7z3Z6jR3LVq4c4s
# Y1dfPmYlw62cbyV9Kb/H2hYw5K0OMX60LfLQZOzIPzAeRJ87NufwZnC1afxsSCmU
# bvSx4kCMgRZMXw+d1SHRhh7z+06YTQjnUMmtTGt7DtUkU6I8LKEWF/mAzF7sq/7P
# AyhPsbu91X5FuzGCA3YwggNyAgEBMIHUMIHGMQswCQYDVQQGEwJVUzERMA8GA1UE
# CBMITmV3IFlvcmsxEjAQBgNVBAcTCVJvY2hlc3RlcjEaMBgGA1UEChMRSHVkZGxl
# ZE1hc3Nlcy5vcmcxHjAcBgNVBAsTFUNlcnRpZmljYXRlIEF1dGhvcml0eTErMCkG
# A1UEAxMiSm9lbCBCZW5uZXR0IENlcnRpZmljYXRlIEF1dGhvcml0eTEnMCUGCSqG
# SIb3DQEJARYYSmF5a3VsQEh1ZGRsZWRNYXNzZXMub3JnAgkAqkNFUy2/QuowCQYF
# Kw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkD
# MQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJ
# KoZIhvcNAQkEMRYEFIav5gxrUCeM18gHLn9rvM7Y9bSfMA0GCSqGSIb3DQEBAQUA
# BIICAClTS+mIW7vAIsYB+MvbqD6oR5BW1TRXq5CAfPLK+XveUmYczvs4Ujx7TBAp
# twJm4rR/nz9cEi+yI12R5YbYmVcfa2gxreXkp3BKWOvhYvfPggh07VssBc7Ik4q+
# ppqdD8tbh1lln8atkGaTfNm3h50es5KADSkMSErXlM+eMNAttnDElKzYszDlLkn4
# VTUrvqorx5kLpk7soOb7NdkqG4FnIBjGgpsCGcfkBZNzdIjJnnaXje5DF6MwLLKv
# kBBXkmLXa4c+NpzDW9BhVa4VvfVPNpEMuOoJ9LxIXp4hWOcD4oAYGYbuqNpTzhsc
# nrgebPHh1RmMbyShYCHIilMeLKJUgJqS7yCp+qAlxfKmtVKUJOMxJXZahDwLVImq
# a89OiBDjsDtE2sKdlfVu+rFOa/itWa0NvMX6Qn5+jo/D//3EddYTPIUQnPjYcdo2
# RveOsun6apOo749M7WSTSCzvkwR86TpQU9sYyrhCMdOPdhDrqRgGwXpjUhzjG4Wl
# Xk18XlpuqAMA7nQlcZ2SSIu7hgEXRR3zP/rXWvjcxan42qai3pFt9JBshieWveE2
# VveewNAv4ltAjE+80DXGf81q92uBB9ym3g9vbRRJY42J/4MG5Z9lL0SbDY54LiJh
# BA/Z0IU5PGgpt5PEpejJqx4o/URH7bZTI5x16NWXhvQDJJyb
# SIG # End signature block
