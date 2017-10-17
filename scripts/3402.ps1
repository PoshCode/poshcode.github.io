# $Excel = New-Object -ComObject Excel.Application

Function Excel-LoadFile {
	Param (
		$SourceFile,
		$ExcelObject
	)
	
	#$excel.visible = $true # Makes Excel document visible on the screen
	$Workbook   = $ExcelObject.Workbooks.Open($SourceFile)
	$Worksheets = $Workbook.Worksheets
	$Worksheet  = $Workbook.Worksheets.Item(1)
	
	return $Worksheet		
}

Function Excel-RowCount {
	Param ($Worksheet)
	
	$range   = $Worksheet.UsedRange
	$rows    = $range.Rows.Count
	$rows    = $rows - 2
	
	return $rows
}

Function Excel-ColumnCount {
	Param ($Worksheet)
	
	$range   = $Worksheet.UsedRange
	$columns = $range.Columns.Count
		
	return $columns
}

Function Excel-ReadHeader {
    Param ($Worksheet)
	
    $Headers =@{}
    $column = 1
    Do {
        $Header = $Worksheet.cells.item(3,$column).text
        If ($Header) {
            $Headers.add($Header, $column)
            $column++
        }
    } until (!$Header)
    $Headers
}

Function Excel-CloseFile {
	Param($ExcelObject)
	
	$ExcelProcess = Get-Process Excel
	$ExcelProcess | ForEach { Stop-Process ( $_.id ) }
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($ExcelObject) | Out-Null
}
