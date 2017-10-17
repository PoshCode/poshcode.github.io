function Get-OleDBPSObject ([string]$ConnectionString, [string]$Query) {
	$ConnObj = new-object System.Data.OleDb.OleDbConnection $ConnectionString
	$command = New-Object System.Data.OleDb.OleDbCommand $Query, $ConnObj
	try {
		$ConnObj.Open()
		[System.Data.OleDB.OleDbDataReader]$reader = $command.ExecuteReader()
		while ($reader.Read()) {
			$obj = New-Object PSObject
			for ($i=0; $i -lt $reader.FieldCount; $i++) {
				$obj | Add-Member -type NoteProperty -name ($reader.GetName($i)) -value ($reader[$i])
			}
			$obj	
		}
	}
	catch { throw $_ }
	finally {
		$command = $null
		$reader.Close()
		$reader = $null
		$ConnObj.Close()
		$ConnObj = $null
	}
}

