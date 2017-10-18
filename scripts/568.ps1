# Code to auto update the Address policy, GAL, OAB and storage groups and mailbox databases of an Exchange 2007 server by John McLear
# This code is good for hosting providers or people who wish to use lots of storage groups and mailbox databases.
# 
# Thanks to Joel Bennett (Jaykul) for general scripting help and the friendly folks in #powershell - freenode
#
# I rewrote this and didnt test before publishing so there may be some syntax errors.
#
# Created 07/09/2008
#################################################################################################################################

param([string]$fullname, [string]$mail2, [string]$typeofcustomer)

# PRE REQ - Create a container in your address lists called "Generic Address Book" or something similar - this is where we will store address lists!
	  - Create a public folder database on your MB server - In $publicfolderDatabase our example is in storage group sg0 called Public Folder.

# We need to set some things manually too!
$yourinternaldomain = "domain.com" # ie contoso.com
$OABDistributionServer = "CASserver" # Your CAS server responsible for OAB distribution
$MailboxServer = "MBserver" # Shortname of your MailboxServer
$PublicFolderDatabase = $MailboxServer + '\sg0\Public Folder' # The Path to your public folder used for Address List distribution
$LogFilePath = "d:\Program Files\Microsoft\Exchange Server\Mailbox\First Storage Group\" # Where we will put the log files
$AdminName = "CN=Servers,CN=Exchange Administrative Group (TESTING23TESTY),CN=Administrative Groups,CN=Contoso,CN=Microsoft Exchange,CN=Services,CN=Configuration,DC=contoso,DC=com" # This needs to be changed

echo "Fullname: $fullname" # full name of customer - this must be a unique value)
echo "Domain name: $mail2" # customers domain name ie fraggle.com
echo "Type of customer (1 is basic, 2 is standard, 3 is premium): $typeofcustomer" # Basically a premium customer will get their own mailboxdatabase - a basic or standard will share in one big database (know why before you use this!)
echo "Your internal domain: $yourinternaldomain" # The internal domain you set 

# Lets go!
######################

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
# Loads exchange snap ins

new-AcceptedDomain -Name $mail2 -DomainName $mail2 -DomainType 'Authoritative'
# Creates an accepted domain

new-EmailAddressPolicy -Name $fullname -IncludedRecipients 'AllRecipients' -ConditionalCompany $fullname -Priority 'Lowest' -EnabledEmailAddressTemplates SMTP:%m@$mail2,smtp:%g@$mail2,smtp:%1g.%s@$mail2,smtp:%m@$yourinternaldomain
# Creates a new address policy giving - you may wish to modify this to suit

set-EmailAddressPolicy -Identity $fullname -IncludedRecipients 'AllRecipients' -ConditionalCompany $fullname -Priority 'Lowest' -EnabledEmailAddressTemplates SMTP:%m@$mail2,smtp:%g@$mail2,smtp:%1g.%s@$mail2,smtp:%m@$yourinternaldomain
# Modifies the new address policy giving - you may wish to modify this to suit - Why modify? You may wish to update this at some point and its best practice to have a set command imho

new-GlobalAddressList -Name $fullname -IncludedRecipients 'AllRecipients' -ConditionalCompany $fullname
# Create a new GAL

new-AddressList -Name $fullname -IncludedRecipients 'AllRecipients' -ConditionalCompany $fullname -Container '\Generic Address Book'
# Create a new address list in the Generic Address Book container - Modify your container to suit!

$fullname2 = '\Generic Address book\' + $fullname
# You may wish to modify the above to suit

$OABPoint = $OABdistributionServer + '\OAB (Default Web Site)'
# You may wish to modify the above line to suit but I doubt it.
new-OfflineAddressBook -Name $fullname -Server $pinkyring -AddressLists $fullname2 -PublicFolderDistributionEnabled $false -VirtualDirectories $OABPoint
# Create a new Offline Address Book
Set-OfflineAddressBook -Identity $fullname -versions Version3, Version4 -PublicFolderDistributionEnabled $true -AddressLists $fullname2 
# Set the OAB to V3, 4 and Public folder distribution.

Update-EmailAddressPolicy -Identity $fullname
# Update the Email Address Policy

Set-MailboxDatabase -Identity $fullname -OfflineAddressBook $fullname -PublicFolderDatabase $PublicFolderDatabase
# Set the Mailbox database of the customer to use the public folder database you created

$maildb = Get-MailboxDataBase | Select-String $fullname
echo $maildb
if ($maildb -match "sg") 
# if there is a database for the fullname value then
	{
	echo "not making the DB"
	}
# if there isnt a school name
	else
	{
	if ($typeofcustomer -match "3")
	# and if the type of customer is 3 (premium)
		{
		echo "making the DB" # this customer must be premium! good for them!!
		$i = 1

			for( $i=0;  $i -lt 50;  $i++ )	
			# for each count 1 to 50
			{
			$maildb = Get-MailboxDataBase | Select-String $fullname
			echo $maildb
				if ($maildb -match "sg") 
				# Check for a database
				{ echo "database located" } # if database is found then do nothing
				else
				{
				new-storagegroup sg$i
				# creating 50 storage groups
				new-mailboxdatabase -StorageGroup $MailboxServer\sg$i -Name $fullname -EdbFilePath $LogFilePath + '\' + $fullname.edb
				# make a database on the server - we need to add incrementation on servername here..
				mount-database -Identity "CN=$fullname,CN=sg$i,CN=InformationStore,CN=$MailboxServer,$AdminName"
				# mount the database
				$i++
				# increase the storage group by 1
				}
			}
			Set-MailboxDatabase -Identity $fullname -PublicFolderDatabase $PublicFolderDatabase
			# set the public folder
	}
	else
	{
	echo "customer is a basic or standard customer so we are going to not create a DB"
	Set-MailboxDatabase -Identity $fullname -OfflineAddressBook $fullname -PublicFolderDatabase $PublicFolderDatabase
	}
}
