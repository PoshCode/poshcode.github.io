# Create a new Excel object using COM
$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $True
$Excel.DisplayAlerts = $False

# Counter variable for rows
$intRow = 1

$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)

#Create column headers
$Sheet.Cells.Item($intRow,1)  = "Software Vendor"
$Sheet.Cells.Item($intRow,1).Font.Bold = $True
$Sheet.Cells.Item($intRow,2)  = "Software Name"
$Sheet.Cells.Item($intRow,2).Font.Bold = $True
$Sheet.Cells.Item($intRow,3)  = "Version"
$Sheet.Cells.Item($intRow,3).Font.Bold = $True
$Sheet.Cells.Item($intRow,4)  = "Estimated Size (KB)"
$Sheet.Cells.Item($intRow,4).Font.Bold = $True
$Sheet.Cells.Item($intRow,5)  = "Installation Date"
$Sheet.Cells.Item($intRow,5).Font.Bold = $True

$Results = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*

foreach ($objResult in $Results)
{
	$intRow++
	$Name = $objResult.DisplayName
	$SizeKB = $objResult.EstimatedSize
	$Version = $objResult.DisplayVersion
	$InstDate = $objResult.InstallDate
	$Vendor = $objResult.Publisher
	$Sheet.Cells.Item($intRow,1) = $Vendor
	$Sheet.Cells.Item($intRow,2) = $Name
	$Sheet.Cells.Item($intRow,3) = $Version
	$Sheet.Cells.Item($intRow,4) = $SizeKB
	$Sheet.Cells.Item($intRow,5) = $InstDate
}

$Sheet.UsedRange.EntireColumn.AutoFit()

$i = 1

$xlCellTypeLastCell = 11
$used = $Sheet.usedRange
$lastCell = $used.SpecialCells($xlCellTypeLastCell)
$row = $lastCell.row
for ($i = 1; $i -le $row; $i++)
{
	If ($Sheet.Cells.Item($i, 1).Value() -eq $Null)
	{
		$Range = $Sheet.Cells.Item($i, 1).EntireRow
		$Range.Delete()
	}
}
