param (
	$UserName,
	$FilePath,
	[switch]$SaveCredential=$False,
	[switch]$RdpSaveCredential=$False,
	[switch]$DeleteCredential=$False,
	[switch]$Help=$False
)

$ScriptFilenam	= $MyInvocation.MyCommand.Name # ScriptFilename wo path.
$ScriptUnbArgs	= $MyInvocation.UnboundArguments # UnNamed Arguments of the PowerShell Script ($Args) 
$CredDir	= $env:UserProfile # sotres credential files
$RdpFilenam	= $env:UserProfile + "\My Documents\Default.rdp"

function Get-ScriptHelp {
Write-Host -ForegroundColor:White "
Usage:`t`t version 2009.10.07 ,karaszmiklos@gmail.com
$ScriptFilenam [-UserName:]UserName [[-FilePath:]program [arg1] ['arg 2'] [arg...]] [-SaveCredential] [-RdpSaveCredential] [-DeleteCredential] [-Help]
-UserName:
  Required parameter! There is no default value.
  1st position if parameter name is not defined.
  Predefined user aliases:
    SU		Local Admin  (SID ending with 500)
    EMA		Domain Admin (UserDomain\uEMAsername)
    Alias1	Default alias for context menus.
  You can define aliases by runing: su AliasName -SaveCred
-FilePath:
  Executable files. Default value:cmd.exe
  2nd position if parameter name is not defined.
-SaveCredential
  Switch parameter. Default value:$False
  Force asking and saving credential into efs encrypted file.
-RdpSaveCredential
  Switch parameter. Default value:$False
  Force saving the specified credential into RDP profile:default.rdp
-DeleteCredential
  Switch parameter. Default value:$False
  Forcing deletion of the specified credential.
-Help
  Switch parameter. Default value:$False
  
.\ means current directory.
Use 'single quotes' for programs and arguments containing spaces.
Partial paramter names can be used while they are not ambiguous.

Examples:
su SU
su EMA
su EMA -Save
su EMA -Rdp
su EMA -Save -RdpSave
su Alias1 -SaveCred
su Alias1 -DeleteCred
su Domain\Username cmd
powershell.exe $ScriptFilenam SU cmd.exe
su SU sc.exe stop ccmexec
powershell.exe $ScriptFilenam SU sc.exe stop ccmexec
su.bat SU 'c:\Directory with spaces\procexp.exe' /t /p:r -accepteula
"
}

function Export-PSCredential { #http://halr9000.com/article/531
	param ( $Credential = (Get-Credential), $Path = "credentials.enc.xml" )
	# Look at the object type of the $Credential parameter to determine how to handle it
	switch ( $Credential.GetType().Name ) {
		# It is a credential, so continue
		PSCredential		{ continue } 
		# It is a string, so use that as the username and prompt for the password
		String				{ $Credential = Get-Credential -credential:$Credential }
		# In all other cases, throw an error and exit
		default				{ Throw "You must specify a credential object to export to disk." }
	}		
	$export = New-Object PSObject # Create temporary object to be serialized to disk
	Add-Member -InputObject $export -Name:Username -Value:$Credential.Username -MemberType:NoteProperty 
	# Encrypt SecureString password using Data Protection API
	$EncryptedPassword = $Credential.Password | ConvertFrom-SecureString
	Add-Member -InputObject:$export -Name:EncryptedPassword -Value:$EncryptedPassword -MemberType:NoteProperty
	$export.PSObject.TypeNames.Insert(0,’ExportedPSCredential’)	# Give object a type name which can be identified later
	$export | Export-Clixml $Path # Export using the Export-Clixml cmdlet
	Write-Host -foregroundcolor:Green "Credential saved to: "
	Get-Item -Force $Path	# Return FileInfo object referring to saved credentials
}

function Import-PSCredential { #http://halr9000.com/article/531
	param ( [string]$Path = "credentials.enc.xml", [string]$CredentialVariable ) 	#to create a global credential with a specified name	
	$import = Import-Clixml $Path # Import credential file
	# Test for valid import
	if ( !$import.UserName -or !$import.EncryptedPassword ) {
		Throw "Input is not a valid ExportedPSCredential object, exiting."
	}
	$Username = $import.Username
	$SecurePass = $import.EncryptedPassword | ConvertTo-SecureString	# Decrypt the password and store as a SecureString object for safekeeping
	$PsCredential = New-Object System.Management.Automation.PSCredential $Username, $SecurePass	# Build the new credential object
	if ($CredentialVariable) {
		New-Variable -Name:$CredentialVariable -Scope:Global -Value:$PsCredential
	} else {
		return $PsCredential
	}
}

if ( $Help ) {
	Get-ScriptHelp
	exit 0;
}

switch ($UserName) {
	$null {
		Write-Host -ForegroundColor:Red "UserName is not defined. Exiting..."
		Get-ScriptHelp
		exit 1;
	}
	"SU"	{
		$CredUsrExpr = '(Get-WmiObject -Query "SELECT * FROM Win32_Account WHERE LocalAccount = True AND SID LIKE ""S-1-5-21-%-500""").Caption'
		$CredFilenam = Join-Path -Path:$CredDir -ChildPath:$($env:COMPUTERNAME+"_S-1-5-21--500")
	}
	"EMA"	{
		$CredUsrExpr = '$env:UserDomain + "\" + $env:UserName[0] + "ema" + $env:UserName.Remove(0,1)'
		$CredFilenam = Join-Path -Path:$CredDir -ChildPath:$($env:UserDomain+"_S-1-5-21--ema")
	}
	default {
		$CredUsrExpr = '$UserName'
		$CredFilenam = Join-Path -Path:$CredDir -ChildPath:$UserName.Replace("\","_")
	}
}


#Test Credential Directory
if ( -not(Test-Path $CredDir) ) {
	New-Item "$CredDir" -Type:Directory -Force -Confirm -Verbose
	if ( -not(Test-Path $CredDir) ) {
		Write-Warning "Credential directory ""$CredDir"" doesn't exist. Exiting..."
		exit 82; # 82 	The directory or file cannot be created.
	}
}

if ( $DeleteCredential ) {
	if ( Test-Path $CredFilenam) {
		Write-Host "Deleting credential:""$CredFilenam"" ..." -ForegroundColor:Yellow
		Remove-Item -Path $CredFilenam -Force -Confirm -Verbose	
		if ( -not(Test-Path $CredFilenam) ) {
			Write-Host -ForegroundColor:Green "$CredFilenam is deleted."
		} else {
			Write-Host -ForegroundColor:Yellow "$CredFilenam has not been deleted."
		}
		exit 0;
	} else {
		Write-Warning "Credential does not exist:$CredFilenam"
		exit 2; # 2 	The system cannot find the file specified.
	}
}

if ( $SaveCredential -or !(Test-Path $CredFilenam) ) {
	try {
		$PsCred = Get-Credential -Credential:(Invoke-Expression $CredUsrExpr)
	}
	catch {
		"$($Error[0])"	
	}
} else {
	#Import Credential from encrypted file (if exists).
	if (Test-Path $CredFilenam) {
		$PsCred = Import-PSCredential -Path:"$CredFilenam"
	} 
}
if ( !$PsCred ) {
	Write-Warning "Credential is not defined. Exiting..."
	exit 1326; # 1326 	Logon failure: unknown user name or bad password.
}

try {
	#Setup arguments of Start-Process based on Script parameters
	if ( $FilePath ) {
		if ( $ScriptUnbArgs ) {
			if ( ( ".exe",".com",".bat",".cmd" | Foreach-Object { $FilePath.EndsWith($_) } ) -contains $True ) {
				Start-Process -LoadUserProfile -Credential:$PsCred -FilePath:$FilePath -ArgumentList:$ScriptUnbArgs
			} else {
				Start-Process -LoadUserProfile -Credential:$PsCred -FilePath:Cmd.exe -ArgumentList:"/C start ""PS_Process_Starter"" /B ""$FilePath"" $ScriptUnbArgs"
			}
		} else { # No args
			if ( ( ".exe",".com",".bat",".cmd" | Foreach-Object { $FilePath.EndsWith($_) } ) -contains $True ) {
				Start-Process -LoadUserProfile -Credential:$PsCred -FilePath:$FilePath
			} else {
				Start-Process -LoadUserProfile -Credential:$PsCred -FilePath:Cmd.exe -ArgumentList:"/C start ""PS_Process_Starter"" /B ""$FilePath"""
			}
		}
	} else {
		Start-Process -LoadUserProfile -Credential:$PsCred -FilePath:Cmd.exe -ArgumentList:"/K Title $($PsCred.UserName):  $($MyInvocation.Line)"
	}
}
catch {
	#Error handling...
	Write-Host -ForegroundColor:Red "runas:$($PsCred.UserName):`t $($MyInvocation.Line)"
	"$($Error[0])"
	#Password has been changed...
	if ( ($Error[0] -match "Logon failure: unknown user name or bad password") -and !$SaveCredential ) {
		if ( Test-Path $CredFilenam ) {
			Write-Host -ForegroundColor:Yellow "Deleting invalid credential. Use -SaveCredential next time to save it again."
			Remove-Item -Path $CredFilenam -Force -Confirm -Verbose	
			if ( -not(Test-Path $CredFilenam) ) {
				Write-Host -ForegroundColor:Green "$CredFilenam is deleted. Exiting..."
			} else {
				Write-Host -ForegroundColor:Yellow "$CredFilenam has not been deleted."
			}
			exit 1326; # Logon failure: unknown user name or bad password.
		}
	} else {
		exit 1;
	}

}

if ( !$Error ) { # There were not errors:
	Write-Host -ForegroundColor:Green "runas:$($PsCred.UserName):`t $($MyInvocation.Line)"
	#Export credential:
	if ( $SaveCredential ) {
		Write-Host "Saving credential:""$CredFilenam"" ..."
		Export-PSCredential -Credential $PsCred -Path "$CredFilenam"
		try { (Get-Item -Force $CredFilenam).Encrypt() }
		catch {
			"$($Error[0])"
		}
		if ((Get-Item -Force $CredFilenam).Attributes -match "Encrypted") {
			Write-Host -ForegroundColor:Green "$((Get-Item -Force $CredFilenam).Attributes)"
		} else {
			Write-Warning "$CredFilenam is not encrypted. Deleting..."
			Remove-Item -Path "$CredFilenam" -Force -Confirm -Verbose
		}
	}
	if ( $RdpSaveCredential ) {
		if (Test-Path $RdpFilenam) {
			Write-Host "Saving credential:""$RdpFilenam"" $((Get-Item -Force $RdpFilenam).Attributes) ..."
			if ( (Get-Item -Force $RdpFilenam).Attributes -notmatch "Encrypted" ) { # ReadOnly, Archive, Encrypted
				(Get-Item -Force $RdpFilenam).Attributes = "Archive"
				try {
					(Get-Item -Force $RdpFilenam).Encrypt()
				}
				catch {
					"$($Error[0])"
				}
			}	# if $RdpFilenam not Encrypted
			(Get-Item -Force $RdpFilenam).Attributes = "ReadOnly, Archive, Encrypted"
			if ( (Get-Item -Force $RdpFilenam).Attributes -notmatch "Encrypted" ) {
				Write-Warning "$RdpFilenam is not encrypted!"
			}
			Write-Host "Creating backup:"
			$RdpFileBak = $RdpFilenam + $(Get-Date -Format:_yyyyMMdd_HHmmss)
			Copy-Item $RdpFilenam $RdpFileBak -Force -Confirm
			if ( Test-Path $RdpFileBak ) {
				if ( !$PsCred.GetNetworkCredential().Domain ) { $PsCred.GetNetworkCredential().Domain = $env:ComputerName }
				$RdpFileLines = switch -regex -File:"$RdpFilenam" {
					"username:s:*"		{ }
					"domain:s:*"		{ }
					"password 51:b:*"	{ }
					default				{ $_ }
				}
				[array] $RdpFileLines	+= "username:s:"	+ $($PsCred.GetNetworkCredential().UserName)
				$RdpFileLines			+= "domain:s:"		+ $($PsCred.GetNetworkCredential().Domain)
				$RdpFileLines			+= "password 51:b:"	+ $($PsCred.Password | ConvertFrom-SecureString)
				Set-Content -Value:$RdpFileLines -Path:$RdpFilenam -Force
				Write-Host "Credential saved:""$RdpFilenam""`t $((Get-Item -Force $RdpFilenam).Attributes)" -ForegroundColor:Green
				$RdpFileLines | Select-Object -Last:3
			}	# if ( Test-Path $RdpFileBak )
		} else {
			Write-Warning "File does not exist:""$RdpFilenam"". Generate an RDP profile first."
			exit 2; # 2 	The system cannot find the file specified.
		}	# if (Test-Path $RdpFilenam)
	}	# if ( $RdpSaveCredential )
	Start-Sleep -Milliseconds 2000
	} else {
	exit 1;
}	# if ( !$Error )


# su.ps1 runs on powershell 2.0 only!	http://connect.microsoft.com/PowerShell
# Put su.ps1 and su.bat to a directory listed in PATH environment variables.
# content of su.bat: (without hashmarks of course :)
#
#@echo off
#PowerShell.exe -ExecutionPolicy RemoteSigned su.ps1 %*
#if NOT [%ErrorLevel%] == [0] (
#	if [%ErrorLevel%] == [9009] (
#		echo PowerShell.exe is not under %%Path%% or Poweshell 2.0 has not been installed.
#		echo http://www.microsoft.com/powershell
#	)
#
#	if NOT [%1] == [] ( echo For usage type su -Help )
#	pause
#)

