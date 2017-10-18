function New-ParameterTransform {
#.Synopsis
#	Generates Parameter Transformation Attributes in simple PowerShell syntax
#.Description
#	New-ParameterTransform allows the creation of .Net Attribute classes which can be applied to PowerShell parameters to transform or manipulate data as it's being passed in.
#.Example
#	Transform TrimBraces {
#		param($string) 
#		if($string -is [String] -and $string.Length -gt 2 -and $string[0] -eq '[' -and $string[-1] -eq ']') { 
#			$string.SubString(1, $string.Length-2) 
#		} else { 
#			$string
#		} 
#	}
#
#	function Where-Type {
#		param(
#			[Type][TrimBraces()][String]
#			[Parameter(Mandatory=$true, Position=0)]
#			$Type,
#			
#			[Parameter(ValueFromPipeline=$true)]
#			$InputObject
#		)
#		process {
#			if($InputObject -is $Type) { $InputObject }
#		}
#	}
#
#   Description
#   -----------
#	This example allows us to pass the "Type" to Where-Type with or without the [Braces] which would normally cause an exception when casting to a type:
#
#	Get-ChildItem | Where-Type IO.FileInfo
#
#	Get-ChildItem | Where-Type [IO.FileInfo]
#
#	Get-ChildItem | Where-Type ([IO.FileInfo])
#
#.Notes
#   It is now possible to redefine transforms by name by running the New-ParameterTransform command again, but type aliases that are generated are bound at function definition time, so any functions that are using the transform before it is redefined must also be redefined to take advantage of the new transform definition.
	[cmdletbinding()]
	param(
		# The name of the parameter transform to generate
		[Parameter(Mandatory=$true,Position=0)]
		[string] $name,
		# The script definition of the parameter transform
		[Parameter(Mandatory=$true, Position=1)]
		[scriptblock] $script
	)

end {
	$className = [Convert]::ToBase64String( ([Guid]::NewGuid().ToByteArray()) ).Replace('+','Ã±').Replace('/','ÃŸ').TrimEnd('=')

	$Type = Add-Type -Passthru -TypeDefinition @"
using System;
using System.ComponentModel;
using System.Management.Automation;
using System.Collections.ObjectModel;

[AttributeUsage(AttributeTargets.Field | AttributeTargets.Property)]
public class ${name}Attribute${className} : ArgumentTransformationAttribute {
   private ScriptBlock _scriptblock;
   private string _noOutputMessage = "Transform Script had no output.";

   public ${name}Attribute${className}() {
      this.Script = ScriptBlock.Create( @"
	  	$($script.ToString() -replace '"','""' )
" );
   }
   public override string ToString() {
      return Script.ToString();
   }

   public override Object Transform( EngineIntrinsics engine, Object inputData) {
      try {
         Collection<PSObject> output =
            engine.InvokeCommand.InvokeScript( engine.SessionState, Script, inputData );
         
         if(output.Count > 1) {
            Object[] transformed = new Object[output.Count];
            for(int i =0; i < output.Count;i++) {
               transformed[i] = output[i].BaseObject;
            }
            return transformed;
         } else if(output.Count == 1) {
            return output[0].BaseObject;
         } else {
            throw new ArgumentTransformationMetadataException(NoOutputMessage);
         }
      } catch (ArgumentTransformationMetadataException) {
         throw;
      } catch (Exception e) {
         throw new ArgumentTransformationMetadataException(string.Format("Transform Script threw an exception ('{0}'). See `$Error[0].Exception.InnerException.InnerException for more details.",e.Message), e);
      }
   }
   
   public ScriptBlock Script {
      get { return _scriptblock; }
      set { _scriptblock = value; }
   }
   
   public string NoOutputMessage {
      get { return _noOutputMessage; }
      set { _noOutputMessage = value; }
   }  
}
"@

	$xlr8r = [psobject].assembly.gettype("System.Management.Automation.TypeAccelerators")
	if($xlr8r::AddReplace) { 
		$xlr8r::AddReplace( ${name}, $Type) 
	} else {
		$null = $xlr8r::Remove( ${name} )
		$xlr8r::Add( ${name}, $Type)
	}
}}

New-Alias -Name Transform -Value New-ParameterTransform;
Export-ModuleMember -Alias Transform -Function *
# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTPVAYxC0ZjgQ4fcYFMPNexV5
# qYegggUrMIIFJzCCBA+gAwIBAgIQHCAgf57pVOnJcjKrMO/dtjANBgkqhkiG9w0B
# AQUFADCBlTELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0
# IExha2UgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYD
# VQQLExhodHRwOi8vd3d3LnVzZXJ0cnVzdC5jb20xHTAbBgNVBAMTFFVUTi1VU0VS
# Rmlyc3QtT2JqZWN0MB4XDTExMDQyNTAwMDAwMFoXDTEyMDQyNDIzNTk1OVowgZUx
# CzAJBgNVBAYTAlVTMQ4wDAYDVQQRDAUwNjg1MDEUMBIGA1UECAwLQ29ubmVjdGlj
# dXQxEDAOBgNVBAcMB05vcndhbGsxFjAUBgNVBAkMDTQ1IEdsb3ZlciBBdmUxGjAY
# BgNVBAoMEVhlcm94IENvcnBvcmF0aW9uMRowGAYDVQQDDBFYZXJveCBDb3Jwb3Jh
# dGlvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANaXR+8W+aH6ofiO
# bZRdIRBuvemJ/8c2fDwbHVLBMieiG9Eqs5+XKZ3M17Sz8GBNzQ4bluk2esIycr9z
# yR/ISBjVxz1RcxH79vuvM6husOAKc2YhnGqA6vmfWokmEfDrOH1qLKA4226tPXBE
# eNTSDrYtXFZ6jYWv9kqGcRMBzV7NPvJwQoMDEl1dbNAXo99RaHGjAfVkCSNYMM11
# jzZ2/DyAqVgKVnNviRQ+Wq8HPxP7Eqg/6b2DVw1Nokg3IDeyFRlo2he09YwVEV+r
# GLvjUBmVRQPauJIr1EUgz85byWtYAUWOXNIFiWrqOKj/Clvi5Y9M05a1TwSi4o0F
# yfa4keECAwEAAaOCAW8wggFrMB8GA1UdIwQYMBaAFNrtZHQUnBQ8q92Zqb1bKE2L
# PMnYMB0GA1UdDgQWBBTKaDgQ0lToUHAI+jy/CDn0BluXFjAOBgNVHQ8BAf8EBAMC
# B4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzARBglghkgBhvhC
# AQEEBAMCBBAwRgYDVR0gBD8wPTA7BgwrBgEEAbIxAQIBAwIwKzApBggrBgEFBQcC
# ARYdaHR0cHM6Ly9zZWN1cmUuY29tb2RvLm5ldC9DUFMwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC51c2VydHJ1c3QuY29tL1VUTi1VU0VSRmlyc3QtT2JqZWN0
# LmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNv
# bW9kb2NhLmNvbTAhBgNVHREEGjAYgRZKb2VsLkJlbm5ldHRAeGVyb3guY29tMA0G
# CSqGSIb3DQEBBQUAA4IBAQAzwUwy00sEOggAavqrNoNeEVr0o623DgG2/2EuTsA6
# 2wI0Arb5D0s/icanshHgWwJZBEMZeHa17Ai/E3foCpj6rA3Y4vIQXHukluiSmjU6
# bWTgF5VbNTpvhlOO6E7Ya/rBr4oj4dqTEErkS7acgBHKrjPOptCiU4BSDqtl0k5z
# OIiawyRSITHYEcCcI0Yl7VIz8EDblOQI3b4JGYcmJ7D+peYrnI2zoQyXDigcIj4l
# VlipnjnvYsF+JbPkQY8XbMO+Yc490Bh8BMXPtuLR1KMuIXPK7DKX7JPmJcY7kKF/
# SPviyk0HE7Rldsses73UF8wT3lgj57FiUqX8FdTa7NllMYICTDCCAkgCAQEwgaow
# gZUxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2FsdCBMYWtl
# IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8GA1UECxMY
# aHR0cDovL3d3dy51c2VydHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNFUkZpcnN0
# LU9iamVjdAIQHCAgf57pVOnJcjKrMO/dtjAJBgUrDgMCGgUAoHgwGAYKKwYBBAGC
# NwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUAZ76oQxT
# FCS/GTPt3vFPxINoPS0wDQYJKoZIhvcNAQEBBQAEggEA0e7s3o95oxMWZXzdu0XE
# c3y1fnKXmgN1gfAFh3lvWQWiiKPBAd0/PBfyAZmendJ7wsLTAafxB21ks74q3WqM
# FJ3/BW8FAZtm8QBuseNkbP3R5pEEhnrEaRo4ZKGez+TfEZe7Swyzo1Vqv8by8a1I
# PCqbZzH6CzU1IR9aoApCvM/OY2Rxp9f4ozdCRqk91Kk6/ryjor/ZJOroAh4ZmEpC
# Z0fRsnKWJ9x3YI8M3dZG53/cBEfaS06GjQvFQasx3BJK1VMQ6suaYYWU4Q/49VWc
# pZ7FhQjw79gZlweVJWENw2dWk2u0OHYTIN+IPVtnLmxgtLRfhenS8TsdjaI3ebUA
# 7w==
# SIG # End signature block

