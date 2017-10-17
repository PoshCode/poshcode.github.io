#####################################################################
# Get-ObjectIdentifier.ps1
# Version 1.0
#
# Resolves OID value to a Friendly Name and vice versa.
#
# Vadims Podans (c) 2010
# http://en-us.sysadmins.lv/
#####################################################################
#requires -Version 2.0

function Get-ObjectIdentifier {
<#
.Synopsis
	Resolves OID value to a Friendly Name and vice versa.
.Description
	Resolves OID value to a Friendly Name and vice versa. The cmdlet resolves both
	well-known OIDs (used in Internet PKI) and Active Directory forest specific
	registered OIDs.
.Parameter OIDString
	Specifies the OID value or Friendly name.
.Example
	Get-ObjectIdentifier "Server Authentication"
	
	Will resolve "Server Authentication" OID to an object identifier value (1.3.6.1.5.5.7.3.1).
.Example
	Get-ObjectIdentifier "1.3.6.1.5.5.7.3.9"
	
	Will resolve "1.3.6.1.5.5.7.3.9" value to a friendly name (OCSP Signing).
.Outputs
	System.Security.Cryptography.Oid
#>
[CmdletBinding()]
[OutputType('System.Security.Cryptography.Oid')]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[String[]]$OIDString
	)
	$OIDString | %{New-Object Security.Cryptography.Oid $OIDString}
}
