########
#
#Used for enumerating local workstation for user details
#Author: Adam Liquorish
#Date: 12/10/11
########

########Define Parameters
param(
[Parameter(Mandatory=$true,
	HelpMessage="Enter Path for output ie c:\Temp\output.html.")]
	[ValidateNotNullOrEmpty()]
	[string]$outputpath=$(Read-Host -prompt "Path for Output"),
[Parameter(Mandatory=$true,
	HelpMessage="Enter ComputerName, enter 'localhost' for current workstation")]
	[ValidateNotNullOrEmpty()]
	[string]$computername=$(Read-Host -prompt "Computername")
)
########END DEFINE PARAMETERS

########Define Variables
if($computername -eq "localhost"){$computername="$env:computername"}
$i=$null
$results=$null
$useroutput=$null
########END DEFINE VARIABLES

########Define HTML Output
$a="<style>"
$a=$a +"TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a=$a +"TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color: thistle}"
$a=$a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
$a=$a + "</style>"
########END DEFINE HTML OUTPUT

#GATHER USERS USING ADSI
$computer=[ADSI]"WinNT://$computerName,computer"
$users=$computer.psbase.Children|Where-object{$_.psbase.schemaclassname -eq 'user'}

#LIST USER PROPERTIES USING .NET
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$domain= "$env:computername"
$ctype = [System.DirectoryServices.AccountManagement.ContextType]::Machine
$principal=new-object System.DirectoryServices.AccountManagement.PrincipalContext $ctype,$domain
$useroutput=foreach($user in $users){
	[System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($principal,$user.name)}
	
#OUTPUT
$results=$useroutput|select-object name,AccountLockoutTime,Enabled,LastLogon,BadLogonCount,LastPasswordSet,LastBadPasswordAttempt,PasswordNotRequired,PasswordNeverExpires,UserCannotChangePassword,AllowReversiblePasswordEncryption
$results|sort-object Name|ConvertTo-Html -head $a -title "Local Users" -body "Local Users"|Set-Content $outputpath
