function Touch-File {
#.SYNOPSIS
#  Port of the UNIX touch command
#.EXAMPLE
#  Touch-File present*.jpg -Time 12.25d
#.LINK
#  Set-ItemProperty
#.NOTES
#  Unlike the UNIX touch, this does NOT create new files
	[CmdletBinding(DefaultParameterSetName='propertyValuePathSet', SupportsShouldProcess, ConfirmImpact='Medium', SupportsTransactions)]
	param(
		[Parameter(ParameterSetName='propertyPSObjectPathSet', Mandatory, Position=0, ValueFromPipelineByPropertyName)]
		[Parameter(ParameterSetName='propertyValuePathSet', Mandatory, Position=0, ValueFromPipelineByPropertyName)]
		[string[]]$Path
,
		[Alias('PSPath')]
		[Parameter(ParameterSetName='propertyPSObjectLiteralPathSet', Mandatory, ValueFromPipelineByPropertyName)]
		[Parameter(ParameterSetName='propertyValueLiteralPathSet', Mandatory, ValueFromPipelineByPropertyName)]
		[string[]]$LiteralPath
,
		[ValidateNotNull()]
		[datetime]$Time = ([datetime]::Now)
,
		[Parameter(ParameterSetName='propertyPSObjectPathSet', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[Parameter(ParameterSetName='propertyPSObjectLiteralPathSet', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[psobject]$InputObject
,
		[switch]$PassThru
,
		[string]$Filter
,
		[string[]]$Include
,
		[string[]]$Exclude
,
		[Parameter(ValueFromPipelineByPropertyName)]
		[pscredential][System.Management.Automation.CredentialAttribute()]$Credential
	)
	begin {
		try {
			$outBuffer = $null
			if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
				$PSBoundParameters['OutBuffer'] = 1
			}
			$PSBoundParameters['Name'] = 'LastWriteTime'
			$PSBoundParameters['Value'] = $Time
			$null = $PSBoundParameters.Remove('Time')
			$wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Set-ItemProperty', [System.Management.Automation.CommandTypes]::Cmdlet)
			$scriptCmd = {& $wrappedCmd @PSBoundParameters }
			$steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
			$steppablePipeline.Begin($PSCmdlet)
		} catch {
			throw
		}
	}
	process {
		try {
			$steppablePipeline.Process($_)
		} catch {
			throw
		}
	}
	end {
		try {
			$steppablePipeline.End()
		} catch {
			throw
		}
	}
}
