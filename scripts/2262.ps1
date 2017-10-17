## Generate two dummy datatables in a dataset for testing
$global:dt1 = New-Object system.data.datatable "Times"
$global:dt2 = New-Object system.data.datatable "Properties"
$global:ds = New-Object system.data.dataset "dataset"
$null = $ds.Tables.Add( $dt1 )
$null = $ds.Tables.Add( $dt2 )

$global:cols1 = ls|?{!$_.PsIsContainer}| gm -type Properties "Name", "CreationTime", "LastAccessTime", "LastWriteTime"
$global:cols2 = ls|?{!$_.PsIsContainer}| gm -type Properties "Name", "Length", "Extension", "Mode", "FullName"

foreach($c in $cols1){
	$null = $dt1.Columns.Add( $c.Name, $($c.Definition -split " ")[0] )
}
foreach($c in $cols2){
	$null = $dt2.Columns.Add( $c.Name, $($c.Definition -split " ")[0] )
}

foreach($f in ls|?{!$_.PsIsContainer}){ 
	$null = $dt1.LoadDataRow( @($cols1 | % { $f.$($_.Name) }), $null )
	$null = $dt2.LoadDataRow( @($cols2 | % { $f.$($_.Name) }), $null )
}

return $ds

# boots { datagrid -itemssource $dt.DefaultView }
