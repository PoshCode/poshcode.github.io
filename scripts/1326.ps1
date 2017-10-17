#=============================================================================#
#=============================================================================#
#=============================================================================#
# 
# SCRIPT		: CreateOrUpdateUsersOrContacts.ps1
# LAST UPDATE		: 9/18/2009
# VERSION		: 1.00
# 
# 
# DESCRIPTION:
# PowerShell script for creating/updating mail-enabled Users or Contact objects
# in Active Directory for Exchange 2003. Uses a CSV source file.
# 
# 
# TO DO:
# 	* Logging.
#	* Roll-back
# 	* Eliminate need to hard-code LDAP fields, use CSV header instead.
#	* Confirm required LDAP fields are present and populated.
#	* Incorporate command-line argument functionality 
#
#		(NOTE: NONE OF THESE HAVE BEEN IMPLEMENTED YET!!!)
#
#		CSV input path and file name
#		$File 		= $args[0]	#	-f <CSV File Name>
# 
#		Type of Active Directory object to target
#		$ADObject	= $args[1]	#	-a <AD Object Type>
#
#		Where the Contacts should be created
#		$OUPath		= $args[2]	#	-o <Target OU Path>
#
#		Which Exchange environment to create contacts in (CHI or LA)
#		$Affiliate	= $args[3]	#	-e <Exchange Environment>
#
#		Test only -- Add 'what if' to New-QADObject
#		$TestFlag	= $args[4]	#	-t
#
#		Domain and username of authentication credentials
#		$UserName 	= $args[5]	#	-u <domain\sAMAccountName>
#
#		Password for above credentials
#		$Password	= $args[6]	#	-p <password>
#
# 
# VERSION HISTORY:
# 1.00 - 8/18/2009
# * Initial Release.
#
#
# AUTHOR:
# Ken Knicker - kenknicker@gmail.com
#
#=============================================================================#
#=============================================================================#
#=============================================================================#


#=============================================================================#
#=============================================================================#
# Functions
#=============================================================================#
#=============================================================================#


#=============================================================================#
Function Set_People_Attributes {
#=============================================================================#
	$Input | Set-QADObject -ObjectAttributes @{
		c 					= ($_.c);
		co 					= ($_.co);
		countryCode 				= ($_.countryCode);
		comment 				= ($_.comment);
		company 				= ($_.company);
		description 				= ($_.description);
		division 				= ($_.division);
		employeeID 				= ($_.employeeID);
		employeeType 				= ($_.employeeType);
		extensionAttribute1			= ($_.extensionAttribute1);
		extensionAttribute2			= ($_.extensionAttribute2);
		extensionAttribute3			= ($_.extensionAttribute3);
		extensionAttribute4			= ($_.extensionAttribute4);
		extensionAttribute5			= ($_.extensionAttribute5);
		extensionAttribute6			= ($_.extensionAttribute6);
		extensionAttribute7			= ($_.extensionAttribute7);
		extensionAttribute8			= ($_.extensionAttribute8);
		extensionAttribute9			= ($_.extensionAttribute9);
		extensionAttribute10			= ($_.extensionAttribute10);
		extensionAttribute11			= ($_.extensionAttribute11);
		extensionAttribute12			= ($_.extensionAttribute12);
		extensionAttribute13			= ($_.extensionAttribute13);
		extensionAttribute14			= ($_.extensionAttribute14);
		extensionAttribute15			= ($_.extensionAttribute15);
		facsimileTelephoneNumber		= ($_.facsimileTelephoneNumber);
		givenName				= ($_.givenName);
		info					= ($_.info);
		initials				= ($_.initials);
		l					= ($_.l);
			# memberOf 				= ($_.memberOf);		# Group memberships
		mobile					= ($_.mobile);
		physicalDeliveryOfficeName		= ($_.physicalDeliveryOfficeName);
		postalCode				= ($_.postalCode);
		sn					= ($_.sn);
		st					= ($_.st);
		streetAddress				= ($_.streetAddress);
		telephoneNumber				= ($_.telephoneNumber);
		title					= ($_.title)
	} -Verbose
}


#=============================================================================#
Function Set_User_Attributes {
#=============================================================================#
	$Input | Set-QADUser -ObjectAttributes @{
		homeDirectory 				= ($_.homeDirectory);
		homeDrive				= ($_.homeDrive);
			# manager 				= ($_.manager);			# Path of user's manager
		mobile					= ($_.mobile);
		profilePath				= ($_.profilePath);
		sAMAccountName				= ($_.sAMAccountName);
		scriptPath 				= ($_.scriptPath);
		userPrincipalName 			= ($_.sAMAccountName + $Domain);
		wWWHomePage				= ($_.wWWHomePage)
	} -Verbose
}


#=============================================================================#
Function Set_Mail_Attributes {
#=============================================================================#
	$Input | Set-QADObject -ObjectAttributes @{
		legacyExchangeDN 			= ($Root_LegacyExchangeDN + $_.mailNickname);
		mail 					= ($_.mail);
		mailNickname				= ($_.mailNickname);
			# msExchHideFromAddressLists		= ($_.msExchHideFromAddressLists);	# TRUE or FALSE
			# msExchHomeServerName			= ($_.msExchHomeServerName);		# Only for User objects
		targetAddress 				= ($_.targetAddress)
	} -Verbose
}


#=============================================================================#
#=============================================================================#
# Script Setup
#=============================================================================#
#=============================================================================#


#=============================================================================#
# Load snap-in for Quest ActiveRoles cmdlets
#=============================================================================#
If (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) {
Add-PSSnapin Quest.ActiveRoles.ADManagement -Verbose
}


#=============================================================================#
# Initialize variables
#=============================================================================#
$CSVPath 		= "\\SERVER\SharePath\ListOfPeople.csv"
$PeopleList 	= Import-Csv $CSVPath -Verbose		# CSV file containing people info
$MailEnable 	= $false

# Set these all to null to clear from last execution.
$ObjectType						= $null
$Domain							= $null
$OU 							= $null
$Root_LegacyExchangeDN					= $null
$Server							= $null
$UserName 						= $null

#=============================================================================#
# Affiliate Number 1 attributes
#=============================================================================#
$Affiliate1_Contact_OU					= "OU=Contacts,DC=affiliate1,DC=com"
$Affiliate1_User_OU					= "OU=Users,DC=affiliate1,DC=com"
$Affiliate1_Root_LegacyExchangeDN			= "/O=Affiliate 1/OU=AFFILIATE1/cn=Recipients/cn="
$Affiliate1_Domain					= "@affiliate1.com"
$Affiliate1_Server					= "domaincontroller.affiliate1.com"

#=============================================================================#
# Affiliate Number 2 attributes
#=============================================================================#
$Affiliate2_Contact_OU					= "OU=Contacts,DC=affiliate2,DC=com"
$Affiliate2_User_OU					= "OU=Users,DC=affiliate2,DC=com"
$Affiliate2_Root_LegacyExchangeDN			= "/O=Affiliate 2/OU=AFFILIATE2/cn=Recipients/cn="
$Affiliate2_Domain					= "@affiliate2.com"
$Affiliate2_Server					= "domaincontroller.affiliate2.com"

#=============================================================================#
# Credentials
#=============================================================================#
$Location = Read-Host "Affiliate location: ''A1'' for Affiliate 1, ''A2'' for Affiliate 2:"
$ObjectType = Read-Host "Object type? ''Contact'' or ''User'':"

If ($Location -eq "AF1") {
	If ($ObjectType -eq "User") { $OU = $Affiliate1_User_OU } 
	Else { $OU = $CHI_Contact_OU }
	$Root_LegacyExchangeDN				= $Affiliate1_Root_LegacyExchangeDN
	$Domain						= $Affiliate1_Domain
	$Server						= $Affiliate1_Server
	$UserName 					= $Affiliate1_UserName
}

If ($Location -eq "AF2") {
	If ($ObjectType -eq "User") { $OU = $Affiliate2_User_OU } 
	Else { $OU = $CHI_Contact_OU }
	$Root_LegacyExchangeDN				= $Affiliate2_Root_LegacyExchangeDN
	$Domain						= $Affiliate2_Domain
	$Server						= $Affiliate2_Server
	$UserName 					= $Affiliate2_UserName
}

$UserName = Read-Host "Enter username for the domain you are connecting to (''DOMAIN\username''):"
$Password = Read-Host "Enter password for"$UserName -AsSecureString
Connect-QADService -Service $Server -ConnectionAccount $UserName -ConnectionPassword $Password -Verbose


#=============================================================================#
#=============================================================================#
# Main Script
#=============================================================================#
#=============================================================================#


#=============================================================================#
# Create or update Contact or User objects from CSV records
#=============================================================================#
$PeopleList | ForEach-Object {

	$Person = Get-QADObject -DisplayName $_.displayName -LdapFilter "(&(objectClass=$ObjectType))" -Verbose

	If ($Person -eq $Null){
		Write-Host "Creating Object for" $_.displayName -ForegroundColor Green -Verbose
		If ($ObjectType -eq "Contact") {
			$Person = New-QADObject -ParentContainer $OU -Name $_.cn -Type $ObjectType -DisplayName $_.displayName -Verbose
		}
		ElseIf ($ObjectType -eq "User") {
			$Person = New-QADUser -ParentContainer $OU -Name $_.cn -DisplayName $_.displayName -SamAccountName $_.sAMAccountName -UserPrincipalName ($_.sAMAccountName+"$Domain") -Verbose
			$Person | Set_User_Attributes
		}
		$Person | Set_People_Attributes
	}
	
	Else {
		Write-Host "Updating Properties for" $_.displayName -ForegroundColor Red -Verbose
		$Person | Set_People_Attributes
	}
	If ($MailEnable -eq $true) {
		$Person | Set_Mail_Attributes
	}
}

#=============================================================================#
# END SCRIPT
#=============================================================================#
