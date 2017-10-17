###########################################################################"
#
# NAME: Set-OCSUser.ps1
#
# AUTHOR: Jan Egil Ring
# EMAIL: jan.egil.ring@powershell.no
#
# COMMENT: Requires Quest AD cmdlets. This oneliner sets Active Directory user attributes for Microsoft Office Communications Server 2007.
#          For more info: http://janegilring.wordpress.com/2009/07/23/manage-ocs-users-with-windows-powershell
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the creator, owner above has no warranty, obligations,
# or liability for such use.
#
# VERSION HISTORY:
# 1.0 23.07.2009 - Initial release
#
###########################################################################"

$Username="demo.user"
$Fullname="Demo User"
$serverpool="pool01.ourdomain.com"

$oa = @{'msRTCSIP-ArchivingEnabled'=0; 'msRTCSIP-FederationEnabled'=$true; 'msRTCSIP-InternetAccessEnabled'=$true; 'msRTCSIP-OptionFlags'=257; 'msRTCSIP-PrimaryHomeServer'=$serverpool; 'msRTCSIP-PrimaryUserAddress'=("sip:$Username@ourdomain.com"); 'msRTCSIP-UserEnabled'=$true }

Set-QADUser $Fullname -oa $oa
