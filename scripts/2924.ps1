function Test-UserCredential {
	[CmdletBinding()] [OutputType([System.Boolean])]
	param(
		[Parameter(Mandatory=$true, ParameterSetName="string", position=0)] 
		[ValidateNotNullOrEmpty()]
		[String] $Username,

		[Parameter(Mandatory=$true, ParameterSetName="string", position=1)] 
		[ValidateNotNullOrEmpty()]
		[String] $Password,
		
		[Parameter(Mandatory=$true, ParameterSetName="PSCredential", ValueFromPipeline=$true, position=0)] 
		[ValidateNotNullOrEmpty()]
		[Management.Automation.PSCredential] $Credential,
		
		[Parameter(position=2)]
		[Switch] $Domain
	)
	
	Begin {
		try { $assem = [system.reflection.assembly]::LoadWithPartialName('System.DirectoryServices.AccountManagement') }
		catch { throw 'Failed to load assembly "System.DirectoryServices.AccountManagement". The error was: "{0}".' -f $_ }
	}
	
	Process {
		try {
			$system = Get-WmiObject -Class Win32_ComputerSystem
			
			if ($PSCmdlet.ParameterSetName -eq 'PSCredential') {
				$Username = $Credential.GetNetworkCredential().UserName
				$Password = $Credential.GetNetworkCredential().Password
			}
		
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
		} catch {
			throw 'Failed to test user credentials. The error was: "{0}".' -f $_
		} finally {
			Remove-Variable -Name Username -ErrorAction SilentlyContinue
			Remove-Variable -Name Password -ErrorAction SilentlyContinue
		}
	}
	
	<#
		.SYNOPSIS
			Validates credentials for local or domain user.
		
		.PARAMETER  Username
			The user's username.
	
		.PARAMETER  Password
			The user's password.
			
		.PARAMETER  Credential
			A PSCredential object created by Get-Credential. This can be pipelined to Test-UserCredential.
	
		.EXAMPLE
			PS C:\> Test-UserCredential -Username andy -password secret
	
		.EXAMPLE
			PS C:\> Test-UserCredential -Username 'mydomain\andy' -password secret -domain

		.EXAMPLE
			PS C:\> Test-UserCredential -Username 'andy' -password secret -domain
			
		.EXAMPLE
			PS C:\> Get-Credential | Test-UserCredential
	
		.INPUTS
			None.
	
		.OUTPUTS
			System.Boolean.
	
		.NOTES
			Revision History
				2011-08-21: Andy Arismendi - Created.
				2011-08-22: Andy Arismendi - Add pipelining support for Get-Credential.	
	#>
}


