function Register-Timer {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[ValidateRange(0.00050000000000000012, 2147483.6474999995)]
		[double]$TimeoutSec
,
		[Parameter(Mandatory, Position = 1)]
		[scriptblock]$Action
,
		[string]$SourceIdentifier
,
#.Parameter SupportEvent
#  Use this to suppress job creation
		[switch]$SupportEvent
,
#.Parameter MessageData
#  Access it via $event.MessageData
		$MessageData = $null
,
		[int]$Count = 1
	)
	$t = [Timers.Timer][int](1000.0*$TimeoutSec)
	$extra = @{}
	if ($PSBoundParameters.ContainsKey('SourceIdentifier')) {
		$extra['SourceIdentifier'] = $SourceIdentifier
	}
	$ret = Register-ObjectEvent -InputObject $t -EventName Elapsed -Action $Action -MessageData $MessageData -MaxTriggerCount $Count -SupportEvent: $SupportEvent @extra
	$t.Start()
	$ret
}
