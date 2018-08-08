function New-PasswordFile
{
	param (
		[parameter(Mandatory = $True)]
		[String]$PasswordFile
	)
	
	Read-Host -AsSecureString "Enter a password" | ConvertFrom-SecureString | Out-File $PasswordFile -ErrorAction Stop
}

function Get-PasswordFromEncryptedFile
{
	param (
		[parameter(Mandatory = $True)]
		[string]$PasswordFile
	)
	
	if (!(Test-Path $PasswordFile))
	{
		throw "Nonexistent Password file"
	}
	
	else
	{
		$EncryptedPass = Get-Content $PasswordFile | ConvertTo-SecureString
		$WncryptedStr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($EncryptedPass)
		[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($WncryptedStr) # Return the unencrypted string
	}
	
}

#Check if password exist else create new passwordfile
if (!(Test-Path C:\password.txt))
{
	New-PasswordFile -PasswordFile "C:\password.txt"
}

#Put password into variable
$Pass = Get-PasswordFromEncryptedFile -PasswordFile "C:\password.txt"
