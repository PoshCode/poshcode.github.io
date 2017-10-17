$dbServer = "servername\instance"
$db = "VeeamBackup"
$veeamJob = "VeeamJobName"
$Query = "SELECT [job_name],CONVERT(char(10),[creation_time], 101) AS start_date `
,CONVERT(varchar, [creation_time], 108) AS job_start,CONVERT(char(10), [end_time], 101) AS end_date `
,CONVERT(varchar, [end_time], 108) AS job_end, `
LEFT(CONVERT(VARCHAR,CAST([end_time] AS DATETIME)-CAST([creation_time] AS DATETIME), 108),5) AS total_time `
FROM [VeeamBackup].[dbo].[BSessions] WHERE [job_name] = '$veeamJob' ORDER BY start_date"

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server=$dbServer;Database=$db;Integrated Security=True"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $Query
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
$SqlConnection.Close()
$DataSet.Tables[0] | Format-Table -AutoSize 
