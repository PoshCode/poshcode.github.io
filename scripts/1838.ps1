###########################################################################
#
# NAME: Invoke-MoveRequest.ps1
#
# AUTHOR: Jan Egil Ring
# EMAIL: jer@powershell.no
#
# COMMENT: Script to use when migrating mailboxes to Microsoft Exchange Server 2010 Cross-Forest. Prepares user objects already 
#          moved to the target forest using Active Directory Migration Tool or other tools, and then invokes the mailbox move request.
#          For more information, see the following blog-post: http://blog.powershell.no/2010/04/23/exchange-server-2010-cross-forest-migration
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the creator, owner above has no warranty, obligations,
# or liability for such use.
#
# VERSION HISTORY:
# 1.0 23.04.2010 - Initial release
#
###########################################################################

#Adding Quest AD PowerShell Commands Snapin and Microsoft Exchange Server 2010 PowerShell Snapin
Add-PSSnapin Quest.ActiveRoles.ADManagement
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010

#Custom variables, edit this section
$TargetDatabase = "Mailbox Database A"
$TargetDeliveryDomain = "domain.com"
$TargetForest="DomainA.local"
$SourceForest="domainB.local"
$SourceForestGlobalCatalog = "dc-01.domainB.local"
$SourceForestCredential = Get-Credential -Credential "Domain\SourceForestAdministrator"

#Connect to source forest to collect users to migrate
Connect-QADService -Service $SourceForest | Out-Null
$SourceForestUsersToMigrate = Get-QADUser -SearchRoot "DomainA.local/Department A/Users"


foreach ($user in $SourceForestUsersToMigrate) {

Write-Host "Processing user $user" -ForegroundColor Yellow

#Connect to source forest to collect source object attributes
Connect-QADService -Service $SourceForest | Out-Null
$TargetObject=$user.samaccountname
$SourceObject=Get-QADUser $TargetObject -IncludeAllProperties
$mail=$SourceObject.Mail
$mailNickname=$SourceObject.mailNickname
[byte[]]$msExchMailboxGUID=(Get-QADuser $SourceObject -IncludedProperties msExchMailboxGUID -DontConvertValuesToFriendlyRepresentation).msExchMailboxGUID
$msExchRecipientDisplayType="-2147483642"
$msExchRecipientTypeDetails="128"
$msExchUserCulture=$SourceObject.msExchUserCulture
$msExchVersion="44220983382016"
$proxyAddresses=$SourceObject.proxyAddresses
$targetAddress=$SourceObject.Mail
$userAccountControl=514

#Connect to target forest to set target object attributes
Connect-QADService -Service $TargetForest | Out-Null
Set-QADUser -Identity $TargetObject -ObjectAttributes @{mail=$mail;mailNickname=$mailNickname;msExchMailboxGUID=$msExchMailboxGUID;msExchRecipientDisplayType=$msExchRecipientDisplayType;msExchRecipientTypeDetails=$msExchRecipientTypeDetails;msExchUserCulture=$msExchUserCulture;msExchVersion=$msExchVersion;proxyAddresses=$proxyAddresses;targetAddress=$targetAddress;userAccountControl=$userAccountControl} | Out-Null

#Update Exchange-attributes (LegacyExchangeDN etc.)
Get-MailUser $TargetObject | Update-Recipient

#Invoking a new move-request
New-MoveRequest -Identity $TargetObject -RemoteLegacy -TargetDatabase $TargetDatabase -RemoteGlobalCatalog $SourceForestGlobalCatalog -RemoteCredential $SourceForestCredential -TargetDeliveryDomain $TargetDeliveryDomain

#Enable target object and unset "User must change password at next logon"
Enable-QADUser -Identity $TargetObject | Out-Null
Set-QADUser -Identity $TargetObject -UserMustChangePassword $false | Out-Null
}
