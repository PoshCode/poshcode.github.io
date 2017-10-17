## Generate a dummy dataset for testing
Param(
   $path = $pwd,
   $files = $(ls $path)
)

$global:dt = New-Object system.data.datatable "datatable"
$global:ds = New-Object system.data.dataset "dataset"
$null = $ds.Tables.Add( $dt )

$global:cols = ls | where {!$_.PsIsContainer} |
   Get-Member -type Properties "Name", "Length", "CreationTime", "LastAccessTime", "LastWriteTime", "Extension", "Mode", "FullName"

foreach($c in $cols){
	$null = $dt.Columns.Add( $c.Name, $($c.Definition -split " ")[0] )
}

foreach($f in ls|?{!$_.PsIsContainer}){ 
	$null = $dt.LoadDataRow( @($cols | % { $f.$($_.Name) }), $null )
}

return $ds
