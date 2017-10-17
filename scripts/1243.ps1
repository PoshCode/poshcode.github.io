#requires -version 2

function Set-EnvironmentVariable {
	param (
		[String] [Parameter( Position = 0, Mandatory = $true )] $Name,
		[String] [Parameter( Position = 1, Mandatory = $true )] $Value,
		[EnvironmentVariableTarget] 
			[Parameter( Position = 2 )]
			$Target = [EnvironmentVariableTarget]::Process, 
		[switch] $Passthru
	)
	[environment]::SetEnvironmentVariable( $Name, $Value, $Target )
	if ( $Passthru ) {
		$result = [environment]::GetEnvironmentVariable( $Name, $Target )
		Write-Output @{ $Name = $Result }
	}
}
