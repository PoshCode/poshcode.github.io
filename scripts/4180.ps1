<#

Add-User script. This script accesses multiple 
PSSessions to add a new user, including creation of a
home directory, Lync creation, Exchange account and 
contact information. 

This script is intended to be run on a domain member server
or workstation. You MUST have the ActiveDirectory powershell module
installed to run this script. I recommend storing and running this 
script on your Default-First-Site domain controller. Be sure to run 
Powershell as administrator. 

WinRM requires additional configuration to run
this script from a machine that isn't joined to the domain.

This script assumes that you have put the account you have
all the correct permissions in Lync/Exchange. 

#>

# Variable Init:

# Global - Server names/Company Name/File locations
$exchangeServer = "exch1.contoso.local"
$lyncServer = "lync1.contoso.local"
$fileserver = "file.contoso.local"
$activeDir = "dc.contoso.local" # Use the DC in the same site as Exchange/Lync
$companyName = "contoso"
$fullCo = "Contoso Fake Inc."
$homedir = "\\$fileServer\HOME$" 
<# Domain users group. When creating home directories, this group will be removed from the 
file permissions #>
$badgroup = "DOMAIN\Users"

<# File where Lync exts are stored. The script is expecting an msdos formatted
   CSV file in the format of username,extension. The user deletion file will 
   remove items from this list as well. #>

$extFile = "\\$fileServer\IT\Documentation\Extensions.csv"

# Lync info
$UMPolicy = "contoso Default Policy"
# Stuff that needs to be set once contoso is on Lync. Will need to mod the Lync command below.
# $VoicePolicy = "contoso Calls"
# $DialPolicy = ""
 

# Prompt for user information
$name = read-host -prompt "Enter the user's first and last name (e.g. John Smith)"
$split = $name.split(" ")
# Creates username in the format: first initial + last name (JSMITH)
$user = $user = $split[0].Substring(0,1)+$split[1]
$upn = $user+"@contoso.local"
$sipSuffix = "@contoso.com"

$department = read-host -prompt "Enter Department"
$desc = read-host -prompt "Employee Title"
$ext = Read-Host -Prompt "User's Lync extension"
$telURI = "tel:+"+$ext

# Get password as secure string
$accountPassword = read-host -AsSecureString -Prompt "Please enter a temporary password"

<# Auto-populate location specific information. Eventually this should all be stored in
   a separate csv document. That would make modifying office information easier and 
   the script would be less cluttered. #>

Write-Host "Choose where this user will be based: "
Write-Host "A) Office 1" 
Write-Host "B) Office 2"
Write-Host "C) Office 3"
Write-Host "D) Office 4"
Write-Host "E) Office 5"
Write-Host "F) Office 6"
Write-Host "G) Office 7"
Write-Host "H) Office 8"
Write-Host "I) Office 9"
Write-Host "J) Office 10"
$selection = Read-Host
	if ($selection.ToUpper() -eq "A") {
		$office = "Office 1"
		$fax = "123-456-7890"
		$phone = "+1123456789;"+"ext="+$ext
		$street = "123 Fake St."
		$zip = "12345"
        $state = "AB"
		$ou = "OU=Office 1,OU=Staff,DC=contoso,DC=ORG"
	}elseif ($selection.ToUpper() -eq "B") {
		$office = "Office 2"
		$fax = "123-456-7890"
		$phone = "+1123456789;"+"ext="+$ext
		$street = "123 Fake St."
		$zip = "12345"
        $state = "AB"
		$ou = "OU=Office 2,OU=Staff,DC=contoso,DC=ORG"
	}elseif ($selection.ToUpper() -eq "C") {
		$office = "Office 3"
		$fax = "123-456-7890"
		$phone = "+1123456789;"+"ext="+$ext
		$street = "123 Fake St."
		$zip = "12345"
        $state = "AB"
		$ou = "OU=Office 3,OU=Staff,DC=contoso,DC=ORG"
	}elseif ($selection.ToUpper() -eq "D") {
		$office = "Office 4"
		$fax = "123-456-7890"
		$phone = "+1123456789;"+"ext="+$ext
		$street = "123 Fake St."
		$zip = "12345"
        $state = "AB"
		$ou = "OU=Office 4,OU=Staff,DC=contoso,DC=ORG"
	}elseif ($selection.ToUpper() -eq "E") {
		$office = "Office 5"
		$fax = "123-456-7890"
		$phone = "+1123456789;"+"ext="+$ext
		$street = "123 Fake St."
		$zip = "12345"
        $state = "AB"
		$ou = "OU=Office 5,OU=Staff,DC=contoso,DC=ORG"
	}elseif ($selection.ToUpper() -eq "F") {
		$office = "Office 6"
		$fax = "123-456-7890"
		$phone = "+1123456789;"+"ext="+$ext
		$street = "123 Fake St."
		$zip = "12345"
        $state = "AB"
		$ou = "OU=Office 6,OU=Staff,DC=contoso,DC=ORG"
	}elseif ($selection.ToUpper() -eq "G") {
		$office = "Office 7"
		$fax = "123-456-7890"
		$phone = "+1123456789;"+"ext="+$ext
		$street = "123 Fake St."
		$zip = "12345"
        $state = "AB"
		$ou = "OU=Office 7,OU=Staff,DC=contoso,DC=ORG"
	}elseif ($selection.ToUpper() -eq "H") {
		$office = "Office 8"
		$fax = "123-456-7890"
		$phone = "+1123456789;"+"ext="+$ext
		$street = "123 Fake St."
		$zip = "12345"
        $state = "AB"
		$ou = "OU=Office 8,OU=Staff,DC=contoso,DC=ORG"
	}elseif ($selection.ToUpper() -eq "I") {
		$office = "Office 9"
		$fax = "123-456-7890"
		$phone = "+1123456789;"+"ext="+$ext
		$street = "123 Fake St."
		$zip = "12345"
        $state = "AB"
		$ou = "OU=Office 9,OU=Staff,DC=contoso,DC=ORG"
	}elseif ($selection.ToUpper() -eq "J") {
		$office = "Office 10"
		$fax = "123-456-7890"
		$phone = "+1123456789;"+"ext="+$ext
		$street = "123 Fake St."
		$zip = "12345"
        $state = "AB"
		$ou = "OU=Office 10,OU=Staff,DC=contoso,DC=ORG"
	}

# Check to see if user has direct-dial number, if so rewrite $phone with correct info
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes",""
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No",""
$choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
$message = "Does this user have a full direct phone number?"
$result = $Host.UI.PromptForChoice($caption,$message,$choices,0)
    if($result -eq 0) { 
        $plainPhone = Read-Host -Prompt "Enter Full DID number, in the format 12223334444" 
        $phone = "+"+$plainPhone+";ext="+$ext }
    if($result -eq 1) { Write-Host "No DID number." }


# Remotely load posh modules
$userCredential = Get-Credential

# Exchange
if ( (Get-PSSession -ComputerName $exchangeServer -ErrorAction SilentlyContinue) -eq $null )
    {
        $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$exchangeserver/PowerShell -Authentication Kerberos -Credential $UserCredential
        Import-PSSession $exchangeSession
    }

# Lync
if ( (Get-PSSession -ComputerName $lyncServer -ErrorAction SilentlyContinue) -eq $null)
    {
        # $lyncOptions = New-PSSessionOption -SkipRevocationCheck -SkipCACheck -SkipCNCheck
        $lyncsession = New-PSSession -ConnectionUri https://$lyncServer/ocspowershell -Credential $userCredential
        Import-PSSession $lyncsession
    }

# ActiveDirectory
if ( (Get-Module -Name ActiveDirectory -ErrorAction SilentlyContinue) -eq $null)
    {
        Import-Module ActiveDirectory
    }

# Ensure the desired username doesn't match any existing sAMAccount or UPN
$saneUser = Get-ADUser -LDAPFilter "(|(sAMAccountName=$user)(UserPrincipalName=$upn))"
if ($saneUser -eq $Null) {
    Write-Host -ForegroundColor Green "The username $user is valid." 
    } Else {
    do {
        $user = Read-Host -Prompt "Already a user with that username. Please input alternate"
        $upn = $user+"@contoso.local"
        $saneUser = Get-ADUser -LDAPFilter "(|(sAMAccountName=$user)(UserPrincipalName=$upn))"
       }  # end Do
    while ($saneUser -ne $Null)
} # end Else

$sip = $user+$sipSuffix
    
# Add the user in Exchange
New-Mailbox -name $name -userprincipalname $upn -Alias $user `
        -OrganizationalUnit $ou -SamAccountName $user -FirstName $FirstName `
        -Initials '' -LastName $Lastname -Password $accountpassword `
        -ResetPasswordOnNextLogon $true

# Pause for AD to catch up
write-host -ForegroundColor Green "Waiting for $activeDir to catch up. Don't touch anything..."
Start-Sleep -s 20

# Set the additional user properties
Set-User -Identity $user -City $office -Company $fullCo -Fax $fax `
        -Phone $phone -PostalCode $zip -StateOrProvince $state `
        -StreetAddress $street -Title $desc -Department $department -Office $office

# Set the ipPhone attribute required by Lync
write-host -ForegroundColor Green "Setting ipPhone info in AD"
$lyncEXT = "+"+$ext
$UserN = Get-ADUser -Identity $user -Properties ipPhone
$UserN.ipPhone = $LyncEXT
Set-ADUser -Server $activeDir -Instance $UserN


# Add user in Lync
Enable-CSUser -Identity $user -RegistrarPool $lyncServer -SipAddress "sip:$sip"
#Start-Sleep -s 10
#Set-CSUser -Identity $username -EnterpriseVoiceEnabled $True -lineuri $telURI

# Enable Unified Messaging
Enable-UMMailbox -Identity $user -UMMailboxPolicy $UMPolicy -Extension $ext -PIN 5673942 -SIPResourceIdentifier $sip -PINExpired $true

# Record extension
echo "$username,$ext" >> $extFile

# Create home directory. This script assumes that you're setting home directories with a GPO
write-host -ForegroundColor Green "Creating user's home directory"
$userdir = "$homedir\$user"
if ( (Test-Path $userdir) -eq $False ) {
    New-Item $homedir -Name $user -ItemType Directory
    $acl = Get-Acl $userdir
    $acl.SetAccessRuleProtection($true,$true)
    $acl.Access |where {$_.IdentityReference -eq $badgroup} | %{$acl.RemoveAccessRule($_)}
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($user, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    $acl.SetOwner([System.Security.Principal.NTAccount] $user)
    Set-Acl -Path $userdir -AclObject $acl } 
Else {
    Write-Host -ForegroundColor Red "User's home directory $userdir exists. Please manually verify."
}

 
write-host -foregroundcolor Green "Pausing to finalize changes, wait for another little bit."
Start-Sleep -s 10
write-host -foregroundcolor Green "Completed. User created: "
Write-Host -foregroundcolor Red "Immediately input new user" $user "into MAILPROTECTOR!"

write-host -foregroundcolor Green "Press any key to exit..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

exit
