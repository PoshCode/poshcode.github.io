Param (
    [Parameter(Mandatory=$true,
        Position=0,
        ValueFromPipeline=$true,
        HelpMessage="Enter SMTP address to search for in Active-Directory."
    )]
    [string]$objSMTP
	)
Function Get-ProxyAddresses ([string]$Address){
$objAD = $null
$objAD = Get-QADObject -LdapFilter "(proxyAddresses=*$Address*)" -IncludeAllProperties -SizeLimit 0 -ErrorAction SilentlyContinue
Write-Output $objAD
}#Close Function
#Validate Quest PSSnapin is loaded
Add-PSSnapin -Name Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue
#Run Function to search AD for SMTP address
$Results = $null
$Results = Get-ProxyAddresses -Address $objSMTP | Select-Object Name,DisplayName,ObjectClass,Email,AccountisDisabled,AccountisLockedOut,MailNickName,LegacyExchangeDN -ErrorAction SilentlyContinue
IF($Results -eq $null){
Write-Host ""
Write-Host "No Object Found with .attribute[proxyAddress] containing $objSMTP."}
Else{$Results | Format-List *}
#End
