$s = "Server01", "Server02", "Server03"
foreach($server in $s) {$server

#$computername = Get-Content env:computername

$filter_Security = '<QueryList> <Query Id="0" Path="Security">
	<Select Path="Security">(*[System[Provider[@Name="Microsoft-Windows-Security-Auditing"] and 
	(Task = 13824 or Task = 13825 or Task = 13826 or Task = 13827 or Task = 13828 or Task = 13829 or
	Task = 13568 or Task = 13569 or Task = 13570 or Task = 13571 or Task = 13572) or
	(Task = 12544 and (band(Keywords,4503599627370496)))]]) or (*[System[Provider[@Name="Microsoft-Windows-Eventlog"] and Task = 104]])
	</Select></Query></QueryList>'

$filter_AcctManagement  = '<QueryList> <Query Id="0" Path="Security">
	<Select Path="Security">*[System[Provider[@Name="Microsoft-Windows-Security-Auditing"] and 
	(Task = 13824 or Task = 13825 or Task = 13826 or Task = 13827 or Task = 13828 or Task = 13829)]]
	</Select></Query></QueryList>'
	
$filter_AuditPolicyChanges  = '<QueryList> <Query Id="0" Path="Security">
	<Select Path="Security">*[System[Provider[@Name="Microsoft-Windows-Security-Auditing"] and 
	(Task = 13568 or Task = 13569 or Task = 13570 or Task = 13571 or Task = 13572 or Task = 13573)]]
	</Select></Query></QueryList>'
	
$filter_FailedLogins  = '<QueryList> <Query Id="0" Path="Security">
	<Select Path="Security">*[System[Provider[@Name="Microsoft-Windows-Security-Auditing"] and 
	(Task = 12544 and (band(Keywords,4503599627370496)))]]
	</Select></Query></QueryList>'
	
$filter_AuditCleared  = '<QueryList> <Query Id="0" Path="Security">
	<Select Path="Security">*[System[Provider[@Name="Microsoft-Windows-Eventlog"] and Task = 104]]
	</Select></Query></QueryList>'
	
$filter_RDP  = '<QueryList> <Query Id="0" Path="Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational">
	<Select Path="Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational">*[System[Provider[@Name="Microsoft-Windows-TerminalServices-RemoteConnectionManager"] and (EventID=1149)]]
	</Select></Query></QueryList>'	

Get-WinEvent -computername $server -FilterXml $filter_RDP | Export-Csv \\networkpath\$server.RDP.csv
Get-WinEvent -computername $server -FilterXml $filter_Security | Select-Object -Property 'Message','ID','Task','RecordID','LogName','ProcessID','ThreadID','MachineName','TimeCreated','TaskDisplayName' | Export-Csv \\networkpath\$server.Security.csv 

