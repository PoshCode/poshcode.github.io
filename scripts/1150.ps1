# Load assembly
[System.Reflection.Assembly]::LoadWithPartialName("Oracle.DataAccess")

# Connection information
$ConnectionString = "Data Source=your_server/sid;User Id=user_name;Password=password"

#Standard SQL Query Syntax
$QueryString = "SELECT * FROM table_name WHERE #Case"

$OracleConnection = New-Object Oracle.DataAccess.Client.OracleConnection($ConnectionString)
$dtSet = New-Object System.Data.DataSet
$OracleAdapter = New-Object Oracle.DataAccess.Client.OracleDataAdapter($QueryString, $OracleConnection)

[void]$OracleAdapter.Fill($dtSet)
