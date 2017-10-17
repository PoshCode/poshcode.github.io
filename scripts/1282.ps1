function KillDBConnections([string]$serverName, [string]$DBName)
{   
    $ConnectionString = "Data Source=$serverName;Initial Catalog=master;Integrated Security=SSPI"
    
    $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString);
    $command = New-Object System.Data.SqlClient.SqlCommand;
    
    $command.Connection = $connection;
    $command.CommandType = [System.Data.CommandType]::Text;    
    $command.CommandText = "SELECT spid FROM master..sysprocesses WHERE dbid=db_id('$DBName')";
    
    $connection.open();
    $reader = $command.ExecuteReader();
    $stringBuilder = New-Object System.Text.StringBuilder

    while ($reader.Read())
    {
        $stringBuilder.AppendFormat("kill {0};", $reader.GetValue(0));
    }
    
    $reader.Close();
    
    $command.CommandText = $stringBuilder.ToString();
    
    if($command.CommandText)
    {        
        $command.ExecuteNonQuery();
    }
    
    $connection.Dispose();
}
