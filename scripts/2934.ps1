# Create a new Excel object using COM
$Excel = New-Object -ComObject Excel.Application
$Excel.visible = $True

# WMI Class variables
$WMI_CSP = "Win32_ComputerSystemProduct"
$WMI_CS = "Win32_ComputerSystem"
$WMI_Disk = "Win32_LogicalDisk"
$WMI_OS = "Win32_OperatingSystem"
$WMI_Proc = "Win32_Processor"

# Set up a directory search for all computer objects in the current domain
$objDomain = New-Object System.DirectoryServices.DirectoryEntry
[string]$DomainName = $objDomain.name
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.Filter = ("(objectCategory=computer)")
$Results = $objSearcher.FindAll()

# Counter variable for rows
$intRow = 1

$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)

#Create column headers
$Sheet.Cells.Item($intRow,1)  = "UUID"
$Sheet.Cells.Item($intRow,1).Font.Bold = $True
$Sheet.Columns.Item('a').ColumnWidth = 42
$Sheet.Cells.Item($intRow,2)  = "Hostname"
$Sheet.Cells.Item($intRow,2).Font.Bold = $True
$Sheet.Columns.Item('b').ColumnWidth = 14
$Sheet.Cells.Item($intRow,3)  = "IP Address"
$Sheet.Cells.Item($intRow,3).Font.Bold = $True
$Sheet.Columns.Item('c').ColumnWidth = 11
$Sheet.Cells.Item($intRow,4)  = "Domain"
$Sheet.Cells.Item($intRow,4).Font.Bold = $True
$Sheet.Columns.Item('d').ColumnWidth = 10
$Sheet.Cells.Item($intRow,5)  = "OS"
$Sheet.Cells.Item($intRow,5).Font.Bold = $True
$Sheet.Columns.Item('e').ColumnWidth = 42
$Sheet.Cells.Item($intRow,6)  = "OS Version"
$Sheet.Cells.Item($intRow,6).Font.Bold = $True
$Sheet.Columns.Item('f').ColumnWidth = 13
$Sheet.Cells.Item($intRow,7)  = "OS Release"
$Sheet.Cells.Item($intRow,7).Font.Bold = $True
$Sheet.Columns.Item('g').ColumnWidth = 11
$Sheet.Cells.Item($intRow,8)  = "Manufacturer"
$Sheet.Cells.Item($intRow,8).Font.Bold = $True
$Sheet.Columns.Item('h').ColumnWidth = 17
$Sheet.Cells.Item($intRow,9)  = "Model"
$Sheet.Cells.Item($intRow,9).Font.Bold = $True
$Sheet.Columns.Item('i').ColumnWidth = 34
$Sheet.Cells.Item($intRow,10) = "Platform"
$Sheet.Cells.Item($intRow,10).Font.Bold = $True
$Sheet.Columns.Item('j').ColumnWidth = 12
$Sheet.Cells.Item($intRow,11) = "Memory (MB)"
$Sheet.Cells.Item($intRow,11).Font.Bold = $True
$Sheet.Columns.Item('k').ColumnWidth = 13
$Sheet.Cells.Item($intRow,12) = "Processors"
$Sheet.Cells.Item($intRow,12).Font.Bold = $True
$Sheet.Columns.Item('l').ColumnWidth = 10
$Sheet.Cells.Item($intRow,13) = "Disk Usage (KB)"
$Sheet.Cells.Item($intRow,13).Font.Bold = $True
$Sheet.Columns.Item('m').ColumnWidth = 15

foreach ($objResult in $Results)	{
	$intRow++

	$objComputer = $objResult.Properties
	[string]$computer = $objComputer.name
	$pingStatus = Get-WMIObject Win32_PingStatus -Filter "Address = '$computer'"
	$ipAddress = $pingStatus.ProtocolAddress
	if($pingStatus.StatusCode -eq 0)	{
		$UUID = Get-WMIObject $WMI_CSP -ComputerName $computer | Select UUID
		$_UUID = $UUID.UUID
		$OS = Get-WMIObject $WMI_OS -ComputerName $computer  | Select Caption
		$_OS = $OS.Caption
		if($_OS)
		{if($_OS.Contains(",")) {$_OS = $_OS.Replace(",","")} if($_OS.Contains("(R)")) {$_OS = $_OS.Replace("(R)","")}}
		$CSDVer = Get-WMIObject $WMI_OS -ComputerName $computer  | Select CSDVersion
		$_CSDVer = $CSDVer.CSDVersion
		$Ver = Get-WMIObject $WMI_OS -ComputerName $computer  | Select Version
		$_Ver = $Ver.Version
		$Mfr = Get-WMIObject $WMI_CSP -ComputerName $computer  | Select Vendor
		$_Mfr = $Mfr.Vendor
		if($_Mfr)
		{if($_Mfr.Contains("HP")) {$_Mfr = $_Mfr.Replace("HP","Hewlett-Packard")}}
		$HW = Get-WMIObject $WMI_CSP -ComputerName $computer  | Select Name
		$_HW = $HW.Name
		$Platform = Get-WMIObject $WMI_Proc -ComputerName $computer -filter "DeviceID = 'CPU0'"  | Select Manufacturer
		$_Platform = $Platform.Manufacturer
		$RAMKB = Get-WMIObject $WMI_CS -ComputerName $computer  | Select TotalPhysicalMemory
		[int64]$_RAMKB = $RAMKB.TotalPhysicalMemory
		[int64]$_RAMMB = $_RAMKB / 1kb
		$Processors = Get-WMIObject $WMI_CS -ComputerName $computer  | Select NumberOfProcessors
		[int64]$NumOfProcs = $Processors.NumberOfProcessors
		$Space = Get-WMIObject $WMI_Disk -ComputerName $computer -filter "DeviceID = 'c:'"  | Select FreeSpace
		[int64]$DiskFree = $Space.FreeSpace
		$Size = Get-WMIObject $WMI_Disk -ComputerName $computer -filter "DeviceID = 'c:'"  | Select Size
		[int64]$DiskSize = $Size.Size
		[int64]$DiskUsage = ($DiskSize - $DiskFree) / 1kb

		# Output minimal information to Console & Complete information to XLS file (Successful Ping)
		Write-Host -ForegroundColor Green "Reply received from $computer ($ipAddress)"
		$Sheet.Cells.Item($intRow,1) = $_UUID
		$Sheet.Cells.Item($intRow,2) = $computer
		$Sheet.Cells.Item($intRow,3) = $ipAddress
		$Sheet.Cells.Item($intRow,4) = $DomainName
		$Sheet.Cells.Item($intRow,5) = $_OS
		$Sheet.Cells.Item($intRow,6) = $_CSDVer
		$Sheet.Cells.Item($intRow,7) = $_Ver
		$Sheet.Cells.Item($intRow,8) = $_Mfr
		$Sheet.Cells.Item($intRow,9) = $_HW
		$Sheet.Cells.Item($intRow,10) = $_Platform
		$Sheet.Cells.Item($intRow,11) = $_RAMMB
		$Sheet.Cells.Item($intRow,12) = $NumOfProcs
		$Sheet.Cells.Item($intRow,13) = $DiskUsage

	}
	else	{
		# Output minimal information to Console & Minimal information to XLS file (Unsucccessful Ping)
		Write-Host -ForegroundColor Red "No Reply received from $computer ....................[SKIPPED]"
		$Sheet.Cells.Item($intRow, 1)  = "HOST NOT ONLINE"
		$Sheet.Cells.Item($intRow, 2)  = $computer
		$Sheet.Cells.Item($intRow, 3)  = "---"
		$Sheet.Cells.Item($intRow, 4)  = $DomainName
		$Sheet.Cells.Item($intRow, 5)  = "---"
		$Sheet.Cells.Item($intRow, 6)  = "---"
		$Sheet.Cells.Item($intRow, 7)  = "---"
		$Sheet.Cells.Item($intRow, 8)  = "---"
		$Sheet.Cells.Item($intRow, 9)  = "---"
		$Sheet.Cells.Item($intRow, 10) = "---"
		$Sheet.Cells.Item($intRow, 11) = "---"
		$Sheet.Cells.Item($intRow, 12) = "---"
		$Sheet.Cells.Item($intRow, 13) = "---"
	}
}
$Sheet.UsedRange.EntireColumn.AutoFit()


Clear
