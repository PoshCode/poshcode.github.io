Param(
    [Parameter(Mandatory=$true)][string]$SiteAddress,
    [Parameter(Mandatory=$true)][string]$WinDomain,
    [Parameter(Mandatory=$true)][string]$DomainController,
    [string]$RestrictAccessToGroup
)

function Generate-Password() {
    $String = -join ([Char[]]'abcdefghijklmnpqrstuvwxyABCDEFGHIJKLMNPQRSTUVWXYZ123456789' | Get-Random -count 12)
    return $String
}

$PrincipalName = "HTTP/$($SiteAddress)@$($WinDomain.ToUpper())"
$KeyTab = "$($SiteAddress).keytab"
$PlainTextPassword = Generate-Password
$Password = ConvertTo-SecureString -String $PlainTextPassword -AsPlainText -Force


if($SiteAddress.Length -gt 20) {
    $Username = $SiteAddress.Substring(0, 20);
} else {
    $Username = $SiteAddress
}

Write-Host "Username: $($Username)"
Write-Host "Password: $($PlainTextPassword)"
Write-Host "Principal name: $($PrincipalName)"

New-ADUser -UserPrincipalName $PrincipalName -Name $Username -Enabled $true -AccountPassword $Password -PasswordNeverExpires $true

Write-Host Password: $PlainTextPassword

ktpass /princ "$($PrincipalName)" /mapuser "$($Username)@$($WinDomain)" /out "C:\$($KeyTab)" /pass "$($PlainTextPassword)" /ptype KRB5_NT_PRINCIPAL

$Parts = @()
Foreach($Part in $WinDomain.Split(".")) {
    $Parts += "DC=$($Part)"
}

$AuthLDAPURL = "ldap://$($DomainController)/$($Parts -join ",")?sAMAccountName"

if($RestrictAccessToGroup) {
    $Require = "ldap-group $((Get-ADGroup $RestrictAccessToGroup).DistinguishedName)"
} else {
    $Require = "valid-user"
}
Write-Host "---------------------------"
Write-Host "httpd.conf:"
Write-Host @"
<Location /krb>
    AuthName "$($SiteAddress)"
    AuthType Kerberos
    KrbServiceName $($PrincipalName)
    Krb5Keytab /etc/httpd/$($KeyTab)
    KrbMethodNegotiate on
    KrbMethodK5Passwd on
    KrbVerifyKDC off
    KrbLocalUserMapping on
    AuthLDAPBindDN $($Username)@$($WinDomain)
    AuthLDAPBindPassword $($PlainTextPassword)
    AuthLDAPURL $AuthLDAPURL
    Require $($Require)
</Location>
"@
Write-Host "---------------------------"
Write-Host "Move $($KeyTab) to /etc/httpd"

