# Make sure SQLite.Interop.dll is in the same directory as System.Data.SQLite.dll

$scriptDir = "Path to your SQLite DLL"

Add-Type -Path "$scriptDir\System.Data.SQLite.dll"


############### SAMPLE USAGE ###################
### Querying:
###
### $readQuery = "SELECT * FROM TABLE"
### $dataArray = $SQLite.querySQLite($readQuery)
###
### Writing:
###
### $writeQuery = "INSERT OR IGNORE INTO TABLE VALUES ('12345', 'TEST');
###                UPDATE GAME SET NAME = 'TEST1235' WHERE ID LIKE '12345';"
### $SQLite.writeSQLite($query)
###
################################################

################################################
###
### $catalog contains two properties ID and NAME
### foreach($item in $catalog ){
###	$writeQuery = "INSERT OR IGNORE INTO GAME VALUES (`"$($item.ID)`", `"$($item.NAME)`");
###					UPDATE GAME SET NAME = `"$($item.NAME)`" WHERE ID LIKE `"$($item.ID)`";"
###	$SQLite.writeSQLite($writeQuery)
### }


$SQLite = New-Module { 

	Function querySQLite {
		param([string]$query)

			$datatSet = New-Object System.Data.DataSet
			
			### declare location of db file. ###
			$database = "$scriptDir\data"
			
			$connStr = "Data Source = $database"
			$conn = New-Object System.Data.SQLite.SQLiteConnection($connStr)
			$conn.Open()

			$dataAdapter = New-Object System.Data.SQLite.SQLiteDataAdapter($query,$conn)
			[void]$dataAdapter.Fill($datatSet)
			
			$conn.close()
			return $datatSet.Tables[0].Rows
			
	}
	
	Function writeSQLite {
		param([string]$query)
		
			$database = "$scriptDir\data"
			$connStr = "Data Source = $database"
			$conn = New-Object System.Data.SQLite.SQLiteConnection($connStr)
			$conn.Open()
			
			$command = $conn.CreateCommand()
			$command.CommandText = $query
			$RowsInserted = $command.ExecuteNonQuery()
			$command.Dispose()
	}
	
	Export-ModuleMember -Variable * -Function * 
} -asCustomObject
