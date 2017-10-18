function Execute-SQLCommand {param(	[string]$Server,								#the host name of the SQL server
									[string]$Database,								#the name of the database
									[System.Data.SqlClient.SqlCommand]$Command)		#the command to execute (name of stored procedure)

	$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
	$sqlConnection.ConnectionString = "Integrated Security=SSPI;Persist Security Info=False;User ID=ml;Initial Catalog=$Database;Data Source=$Server"
	
	$Command.CommandType = 1 # 1 is the 'Text' command type
	$Command.Connection = $sqlConnection
	
	$sqlConnection.Open()
	$Result = $Command.ExecuteNonQuery()
	$sqlConnection.Close()
	
	if ($Result -gt 0) {return $TRUE} else {return $FALSE}
}
