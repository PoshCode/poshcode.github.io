function Invoke-Sqlcmd2
{
    param
    (
        [string]$ServerInstance="localhost",
        [string]$Database,
        [string]$Query,
        [Int32]$CommandTimeout=30
    )
    
    $connectionString = "Server={0};Database={1};Integrated Security=True" -f $ServerInstance, $Database
    $connection = New-Object System.Data.SqlClient.SQLConnection($connectionString)
    
    try
    {
        $connection.Open()
        
        $command = $connection.CreateCommand()
        $command.CommandTimeout = $QueryTimeout
        $command.CommandType = [System.Data.CommandType]::Text
        $command.CommandText = $Query
        
        $dataSet = New-Object System.Data.DataSet
        $dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
        [void]$dataAdapter.Fill($dataSet)
        $dataSet.Tables[0]
    }
    finally
    {
        if ($connection.State -eq [System.Data.ConnectionState]::Open)
        {
            $connection.Close()
        }
    }
}
