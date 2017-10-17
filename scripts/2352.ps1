#requires -Version 2.0
function Get-PrivateKeyPath
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
		[System.Security.Cryptography.X509Certificates.X509Certificate2]
		[ValidateScript( { ( $_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] ) } ) ]
		$Certificate,
		
		[string]
		[ValidateSet('TrustedPublisher','Remote Desktop','Root','REQUEST','TrustedDevices','CA','Windows Live ID Token Issuer','AuthRoot','TrustedPeople','AddressBook','My','SmartCardRoot','Trust','Disallowed')]
		$StoreName = 'My',
		
		[string]
		[ValidateSet('LocalMachine','CurrentUser')]
		$StoreScope = 'CurrentUser'
	)
	begin
	{
		Add-Type -AssemblyName System.Security
	}
	
	process 
	{
		if ($Certificate.PrivateKey -eq $null){Write-Error ("Certificate doesn't have Private Key") -ErrorAction:Stop}
			
		Switch ($StoreScope)
		{
			"LocalMachine" { $PrivateKeysPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonApplicationData) + "\Microsoft\Crypto\RSA\MachineKeys"	}
			"CurrentUser" { $PrivateKeysPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData) + "\Microsoft\Crypto\RSA" }
		}

        $PrivateKeyPath = $PrivateKeysPath + "\" + $Certificate.PrivateKey.CspKeyContainerInfo.UniqueKeyContainerName
		$PrivateKeyPath
	}
	end
	{ }
}

