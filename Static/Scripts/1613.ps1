###########################################################################"
#
# NAME: SPNValidation.psm1
#
# AUTHOR: Jan Egil Ring
# BLOG: http://blog.crayon.no/blogs/janegil
#
# COMMENT: Script module for validating SPN mappings.
#          For installation instructions and sample usage, see the following blog post:
#http://blog.crayon.no/blogs/janegil/archive/2010/01/28/validate_2D00_spn_2D00_mappings_2D00_using_2D00_windows_2D00_powershell.aspx
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the creator, owner above has no warranty, obligations,
# or liability for such use.
#
# VERSION HISTORY:
# 1.0 28.01.2010 - Initial release
#
###########################################################################"

function Resolve-SPN {
################################################################
#.Synopsis
#  Resolves the provided SPN and checks for duplicate entries
#.Parameter SPN
#  The SPN to perform the check against
################################################################
param( [Parameter(Mandatory=$true)][string]$SPN)

$Filter = "(ServicePrincipalName=$SPN)"
$Searcher = New-Object System.DirectoryServices.DirectorySearcher
$Searcher.Filter = $Filter
$SPNEntry = $Searcher.FindAll()
$Count = $SPNEntry | Measure-Object

if ($Count.Count -gt 1) {
Write-Host "Duplicate SPN Found!" -ForegroundColor Red -BackgroundColor Black
Write-Host "The following Active Directory objects contains the SPN $SPN :"
$SPNEntry | Format-Table Path -HideTableHeaders
}

elseif ($Count.Count -eq 1) {
Write-Host "No duplicate SPN found" -ForegroundColor Green
Write-Host "The following Active Directory objects contains the SPN $SPN :"
$SPNEntry | Format-Table Path -HideTableHeaders
}

else

{
Write-Host "SPN not found"
}
}

#Imports the PowerShell ActiveDirectory available in Windows Server 2008 R2 and Windows 7 Remote Server Administration Tools (RSAT)
Import-Module ActiveDirectory

function Resolve-AllDuplicateDomainSPNs {
################################################################
#.Synopsis
#  #  Resolves all domain SPNs and checks for duplicate entries
################################################################

$DomainSPNs = Get-ADObject -LDAPFilter "(ServicePrincipalName=*)" -Properties ServicePrincipalName

foreach ($item in $DomainSPNs) {
$SPNCollection = $item.ServicePrincipalName

foreach ($SPN in $SPNCollection){
$Filter = "(ServicePrincipalName=$SPN)"
$Searcher = New-Object System.DirectoryServices.DirectorySearcher
$Searcher.Filter = $Filter
$SPNEntry = $Searcher.FindAll()
$Count = $SPNEntry | Measure-Object

if ($count.Count -gt 1) {
Write-Host "Warning: Duplicate SPN Found!" -ForegroundColor Red -BackgroundColor Black
Write-Host "The following Active Directory objects contains the SPN $SPN :"
$SPNEntry | Format-Table Path -HideTableHeaders
 }
 }
 }
}
