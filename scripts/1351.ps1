###########################################################################"
#
# NAME: Set-ADUserRandomPassword.ps1
#
# AUTHOR: Jan Egil Ring
# EMAIL: jan.egil.ring@powershell.no
#
# COMMENT: This script are used to set a random password for the Active Directory user with the username provided by the user who runs the script.
#          The password are set to a random password, and "User must change password at next logon" are enabled.
#          At last the displayname,username,company-name,department-name and the new password are displayed.
#          Script logic to check if the provided username exist are added.
#          
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the creator, owner above has no warranty, obligations,
# or liability for such use.
#
# VERSION HISTORY:
# 1.0 29.09.2009 - Initial release
#
###########################################################################"
 
#requires -pssnapin Quest.ActiveRoles.ADManagement

#Creating system.random object used to generate random numbers
$random = New-Object System.Random

#Set searchroot
$searchroot = "domain.local/Example-OU"

#Get username for the user to reset password for
$username = Read-Host "Enter username for the user you want to change password for:"
$userobject = Get-QADUser $username -SearchRoot $searchroot


if ($userobject -ne $null) {
#User exist, continue
}
else
{
#User does not exist, ask user to enter username again
do { $username = Read-Host "There are no users with the username $username. Re-enter username.";$userobject = Get-QADUser $username -SearchRoot $searchroot } until ($userobject -ne $null) 
$userobject = Get-QADUser $username -SearchRoot $searchroot
}

#Generate a random password for each user
$password = "Pwd"+($random.Next(1000,9999))

#Set the password for each user
Set-QADUser $userobject -UserPassword $password -UserMustChangePassword $true | Out-Null

#Select what user information we want to export to the csv-file and storing it in a variable
$userdata = Get-QADUser $userobject | Select-Object @{Name="Name"; Expression = {$_.displayname}},@{Name="Username"; Expression = {$_.samaccountname}},@{Name="Company-name"; Expression = {$_.company}},@{Name="Department-name"; Expression = {$_.department}}

#Add the password as a member to $userdata
Add-Member -InputObject $userdata -MemberType NoteProperty -Name "New password" -Value $password -Force

#Feedback
Write-Host "The password-change was successfully for the following user:"
$userdata
Write-Host "Note: The user must change the password on the next logon."
