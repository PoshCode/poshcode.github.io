function Test-UserCredential {
	[CmdletBinding()] [OutputType([System.Boolean])]
	param(
		[Parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()]
		[System.String] $Username,

		[Parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()]
		[System.String] $Password,
		
		[Parameter()]
		[Switch] $Domain
	)
	
	Begin {
		$assembly = [system.reflection.assembly]::LoadWithPartialName('System.DirectoryServices.AccountManagement')
	}
	
	Process {
		try {
			$system = Get-WmiObject -Class Win32_ComputerSystem
			if ($Domain) {
				if (0, 2 -contains $system.DomainRole) {
					throw 'This computer is not a member of a domain.'
				} else {
					$principalContext = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext 'Domain', $system.Domain
				}
			} else {
				$principalContext = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext 'Machine', $env:COMPUTERNAME
			}
			
			return $principalContext.ValidateCredentials($Username, $Password)
		}
		catch {
			throw 'Failed to test user credentials. The error was: "{0}".' -f $_
		}
	}
	
	<#
		.SYNOPSIS
			Validates credentials for local or domain user.
		
		.PARAMETER  Username
			The user's username.
	
		.PARAMETER  Password
			The user's password.
	
		.EXAMPLE
			PS C:\> Test-UserCredential -Username andy -password secret
	
		.EXAMPLE
			PS C:\> Test-UserCredential -Username 'mydomain\andy' -password secret -domain

		.EXAMPLE
			PS C:\> Test-UserCredential -Username 'andy' -password secret -domain
	
		.INPUTS
			None.
	
		.OUTPUTS
			System.Boolean.
	
		.NOTES
			Revision History
				2011-08-21: Andy Arismendi - Created.	
	#>
}
