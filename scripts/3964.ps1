$ServerInstance = "YourCMSServerInstance"
$query = @"
SELECT DISTINCT s.name
FROM msdb.dbo.sysmanagement_shared_registered_servers s
JOIN msdb.dbo.sysmanagement_shared_server_groups g
ON s.server_group_id = g.server_group_id
"@

$servers = sqlcmd -S "$ServerInstance" -d "master" -Q "SET NOCOUNT ON; $query" -h -1 -W | % {$_ -replace "\\.*",""} | sort -unique
$servers | % { Get-WMIObject -ComputerName $_ -Query "SELECT * FROM CIM_DataFile WHERE Drive ='C:' AND Path='\\WINDOWS\\system32\\CpqMgmt\\' AND FileName='agentver' AND Extension='dll'" } |
 Select CSName, Version, @{n='OS';e={(gwmi win32_operatingsystem -ComputerName $_.CSName).Version}} | ogv
