#####################################################################
# Deny certificate request.ps1
# Version 1.0
#
# Denies certificate request from a pending request
#
# For this function to succeed, the certificate request must be pending
#
# Vadims Podans (c) 2010
# http://en-us.sysadmins.lv/
#####################################################################
#requires -Version 2.0

function Deny-PendingRequest {
[CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFomPipeline = $true)]
        [string]$CAConfig,
        [Parameter(Mandatory = $true)]
        [int]$RequestID
    )
    try {$CertAdmin = New-Object -ComObject CertificateAuthority.Admin}
    catch {Write-Warning "Unable to instantiate ICertAdmin2 object!"; return}
    try {$CertAdmin.DenyRequest($CAConfig,$RequestID)}
    catch {$_; return}
    Write-Host "Successfully denied request '$RequestID'"
}
