# The trigger
$obj = New-Object system.Net.NetworkInformation.Ping
100..200 | % { $ip = "10.1.1.$_"
$ping = $obj.send($ip,100)
write-host "." -noNewLine
if ($ping.status -eq "Success"){
   C:\Powershell\Finduser.ps1 $ping.address.ipaddresstostring
}}

#--------------------------------

# Finduser.ps1
param (
        [string]$strcomputer,
        [switch]$delete)

  $computer = [ADSI]("WinNT://" + $strComputer + ",computer")
 
  $Users = $computer.psbase.children |where{$_.psbase.schemaclassname -eq "User"}
  foreach ($member in $Users.psbase.syncroot){
    if ($member.name -eq "username"){
      write-host Found user! $computer.name
      if ($delete){
        write-host Deleting...
        .\set-localaccount.ps1 -UserName username -remove -computerName $computer.name
      }
    }
  }

#--------------------------------

# set-localaccount.ps1
##################################################################################
#
#  Script name: Set-LocalAccount.ps1
#  Author:      niklas.goude@zipper.se
#  Homepage:    www.powershell.nu
#
##################################################################################

param([string]$UserName, [string]$Password, [switch]$Add, [switch]$Remove, [switch]$ResetPassword, [switch]$help, [string]$computername)

function GetHelp() {
$HelpText = @"
DESCRIPTION:

NAME: Set-LocalAccount.ps1
Adds or Removes a Local Account

PARAMETERS:

-UserName        Name of the User to Add or Remove (Required)
-Password        Sets Users Password (optional)
-Add             Adds Local User (Optional)
-Remove          Removes Local User (Optional)
-ResetPassword   Resets Local User Password (Optional)
-help            Prints the HelpFile (Optional)

SYNTAX:

.\Set-LocalAccount.ps1 -UserName nika -Password Password1 -Add
Adds Local User nika and sets Password to Password1

.\Set-LocalAccount.ps1 -UserName nika -Remove
Removes Local User nika

.\Set-LocalAccount.ps1 -UserName nika -Password Password1 -ResetPassword
Sets Local User nika's Password to Password1

.\Set-LocalAdmin.ps1 -help
Displays the helptext
"@
$HelpText
}

function AddRemove-LocalAccount ([string]$UserName, [string]$Password, [switch]$Add, [switch]$Remove, [switch]$ResetPassword, [string]$computerName) {
    if($Add) {
        [string]$ConnectionString = "WinNT://$computerName"
        $ADSI = [adsi]$ConnectionString
        $User = $ADSI.Create("user",$UserName)
        $User.SetPassword($Password)
        $User.SetInfo()
    }

    if($Remove) {
        [string]$ConnectionString = "WinNT://$computerName"
        $ADSI = [adsi]$ConnectionString
        $ADSI.Delete("user",$UserName)
    }

    if($ResetPassword) {
        [string]$ConnectionString = "WinNT://" + $ComputerName + "/" + $UserName + ",user"
        $Account = [adsi]$ConnectionString
        $Account.psbase.invoke("SetPassword", $Password)
    }
}

if($help) { GetHelp; Continue }
if($UserName -AND $Password -AND $Add -AND !$ResetPassword) { AddRemove-LocalAccount -UserName $UserName -Password $Password -Add -computerName $computerName}
if($UserName -AND $Password -AND $ResetPassword) { AddRemove-LocalAccount -UserName $UserName -Password $Password -ResetPassword -computerName $computerName}
if($UserName -AND $Remove) { AddRemove-LocalAccount -UserName $UserName -Remove -computerName $computerName}
