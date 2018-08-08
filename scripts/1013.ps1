function Run-Query($siteUrl, $queryText)
{
	[reflection.assembly]::loadwithpartialname("microsoft.sharePOint") | out-null
	[reflection.assembly]::loadwithpartialname("microsoft.office.server") | out-null
	[reflection.assembly]::loadwithpartialname("microsoft.office.server.search") | out-null
	$s = [microsoft.sharepoint.spsite]$siteUrl
	$q = new-object microsoft.office.server.search.query.fulltextsqlquery -arg $s
	$q.querytext = $queryText
	$q.RowLimit = 100
	$q.ResultTypes = "RelevantResults"
	$dt = $q.Execute()
	$r = $dt["RelevantResults"]

	$output = @()
	
	while ($r.Read()) {
		$o = new-object PSObject

		0..($r.FieldCount-1) | foreach {
			add-member -inputObject $o -memberType "NoteProperty" -name $r.GetName($_) -value $r[$_].ToString()
		}
		
		
		$output += $o
	}
	
	return $output
}

@@#Sample usage:
@@#Run-Query -siteUrl "http://dev/" -queryText "SELECT PreferredName, WorkPhone FROM S"

