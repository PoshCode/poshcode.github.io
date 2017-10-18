"       -------------------------------------------"
"       ##     FTP VIRTUAL DIRECTORY CREATION SCRIPT     ##"
""
""
"       ## This script will create a new username, password, local directory, and virtual directory for a client "
""
"       ## Please enter the following information "
""
"       -------------------------------------------"
 
 
### PowerShell Script
### Create local User Acount
 
$AccountName = Read-Host "Please enter user account name (i.e. krisp)"
$FullName = Read-Host "Please enter the full name (i.e. Kris)"
$Description = Read-Host "Please enter the description (i.e. Krisp FTP Login)"
$Password = Read-Host "Please enter a password"
$Computer = "FTPSERVER"
 
"Creating user on $Computer"
 
# Access to Container using the COM library
$Container = [ADSI] "WinNT://$Computer"
 
# Create User
$objUser = $Container.Create("user", $Accountname)
$objUser.Put("Fullname", $FullName)
$objUser.Put("Description", $Description)
 
# Set Password
$objUser.SetPassword($Password)
 
# Save Changes
$objUser.SetInfo()
 
# Add User Flags
# The numbers are bitwise - 65536 is Password Never Expires ; 64 is User Cannot Change Password
 
$objUser.userflags = 65536 -bor 64
$objUser.SetInfo()
 
"User $AccountName created!"
" ------------------------" 



#	---Create FTP local directory---

"Creating directory D:\FTP\$AccountName"

New-Item D:\FTP\$AccountName -type directory  
Start-Sleep -Seconds 5
"Directory $AccountName created!"
" ------------------------"


#	---Set Permissions on Folder

"Setting Permissions on D:\FTP\$AccountName"

$colRights = [System.Security.AccessControl.FileSystemRights]"Modify"
$Inherit = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
$Propagate = [System.Security.AccessControl.PropagationFlags]::None
$objType =[System.Security.AccessControl.AccessControlType]::Allow
$User = New-Object System.Security.Principal.NTAccount("$Computer\$AccountName")
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($User, $colRights , $Inherit, $Propagate, $objType)

$objACL = Get-Acl "D:\FTP\$AccountName"

$objACL.AddAccessRule($objACE)

Set-Acl "D:\FTP\$AccountName" $objACL

Start-Sleep -Seconds 5

"Permissions Successfully Applied!"
" ------------------------"




#	---Add User to FTP Users Local Group

"Adding User to FTP Users Group"


$group = [ADSI]"WinNT://$computer/FTP Users"
$group.add("WinNT://$computer/$AccountName") 

"User Added!"
"-------------------------" 





#	---Create Temporary File with Username

$accountname | Out-File name.txt     # <----IIS part won't take direct input, wants to read from file.  Need to Research




#	---Create Virtual Directory in IIS---

"Creating virtual directory in IIS"
Start-Sleep -Seconds 5
foreach ($a in get-content name.txt)
{
$server = $env:computername
$service = New-Object System.DirectoryServices.DirectoryEntry("IIS://$server/MSFTPSVC")
$site = $service.psbase.children |Where-Object { $_.ServerComment -eq 'IntFTP' }
$site = New-Object System.DirectoryServices.DirectoryEntry($site.psbase.path+"/Root") for IIS 7.
$virtualdir = $site.psbase.children.Add("$a","IIsFtpVirtualDir")
$virtualdir.psbase.CommitChanges()
$virtualdir.put("Path","D:\FTP\$a")
$virtualdir.put("AccessRead",$true)
$virtualdir.put("AccessWrite",$true)
$virtualdir.psbase.CommitChanges()
$service.psbase.refreshCache() # OPTIONAL

}

"FTP site $AccountName created!"
" ------------------------"


