Import-Module ActiveDirectory

# Folder to save result file to
@@ $SaveTo = "\\server\share\folder"
$BaseFilename = "Local Admin Group Members.xlsx"
	# The current date and time will be prepended to the BaseFilename

# Exchange settings
$SMTP = "Exch-Srvr"
$Recipients = @("Someone@anywhere.com", "SomeoneElse@anywhere.com", "Nobody@anywhere.com", "Anonymouse@somewhere-else.com")
$Sender = "DeadPool@chimichanga.com"

# Create a new Excel object using COM
$Excel = New-Object -ComObject Excel.Application
$Excel.visible = $False

# Counter variable for rows
$i = 1

# WMI Class variables
$WMI_CSP = "Win32_ComputerSystemProduct"

# Set up a directory search for all computer objects in the current domain
# Exclude several Organizational Units from the search scope
$ExcludeOUs=([adsisearcher]'(&(objectCategory=Organizationalunit)(!ou=Domain Controllers)(!ou=Servers))').FindAll()
foreach($ou in $ExcludeOUs)
{
	$searcher=[adsisearcher]'(&(objectCategory=computer))'
	$searcher.searchScope="Subtree"
	$searcher.searchRoot=$ou.Path
	$Results = $searcher.FindAll()

# Create spreadsheet
$intRow = 1

$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)

# Create column headers
$Sheet.Cells.Item($intRow,1)  = "Hostname"
$Sheet.Cells.Item($intRow,1).Font.Bold = $True
$Sheet.Cells.Item($intRow,1).HorizontalAlignment = -4108
$Sheet.Columns.Item('a').ColumnWidth = 14

$Sheet.Cells.Item($intRow,2)  = "IP Address"
$Sheet.Cells.Item($intRow,2).Font.Bold = $True
$Sheet.Cells.Item($intRow,2).HorizontalAlignment = -4108
$Sheet.Columns.Item('b').ColumnWidth = 11

$Sheet.Cells.Item($intRow,3) = "Serial Number"
$Sheet.Cells.Item($intRow,3).Font.Bold = $True
$Sheet.Cells.Item($intRow,3).HorizontalAlignment = -4108
$Sheet.Columns.Item('c').ColumnWidth = 16

$Sheet.Cells.Item($intRow,4) = "Local Administrators"
$Sheet.Cells.Item($intRow,4).Font.Bold = $True
$Sheet.Cells.Item($intRow,4).HorizontalAlignment = -4108
$Sheet.Columns.Item('d').ColumnWidth = 50

# Parse the search results
foreach ($objResult in $Results)	{
	$intRow++

	$objComputer = $objResult.Properties
	[string]$computer = $objComputer.name
	Write-Host -ForegroundColor White "     Pinging $computer..."
	$pingStatus = Get-WMIObject Win32_PingStatus -Filter "Address = '$computer'"
	$ipAddress = $pingStatus.ProtocolAddress
	if($pingStatus.StatusCode -eq 0)	{
		$Serial = Get-WMIObject $WMI_CSP -ComputerName $computer  |  Select IdentifyingNumber
		$_Serial = $Serial.IdentifyingNumber

		$members =[ADSI]"WinNT://$Computer/Administrators"
		$members = @($members.psbase.Invoke("Members"))
		$_Members = $members | ?{$_ -notlike "administrator" -and $_ -notlike "Domain Admins"} | foreach {
			$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null), ", "
		} | ?{$_ -notlike "administrator" -and $_ -notlike "Domain Admins"}


		# Output Minimal information to Console & Complete information to XLS file (Successful Ping)
		Write-Host -ForegroundColor Green "Reply received from $computer ($ipAddress)"
		Write-Host ""
		$Sheet.Cells.Item($intRow, 1)   = $computer
		$Sheet.Cells.Item($intRow, 2)   = $ipAddress
		$Sheet.Cells.Item($intRow, 3)   = $_Serial
		$Sheet.Cells.Item($intRow, 4)   = "$_Members"

	}
	else	{
		# Output Minimal information to Console & Minimal information to XLS file (Unsuccessful Ping)
		Write-Host -ForegroundColor Red "No Reply received from $computer ....................[SKIPPED]"
		Write-Host ""


		$Sheet.Cells.Item($intRow, 1)   = $computer
		$Sheet.Cells.Item($intRow, 2)   = "HOST NOT ONLINE"

		$Sheet.Cells.Item($intRow, 3)   = "---"
		$Sheet.Cells.Item($intRow, 3).HorizontalAlignment = -4108
		
		$Sheet.Cells.Item($intRow, 4)   = "---"
		$Sheet.Cells.Item($intRow, 4).HorizontalAlignment = -4108
	}
}
}

# Resize columns based on data size
$Sheet.UsedRange.EntireColumn.AutoFit()

# Save and close the spreadsheet. Name with the date and time.
$Date = Get-Date -UFormat "%Y%m%d"
$DateTime = Get-Date -UFormat "%Y%m%d.%H%M"
$Excel.SaveAs("$SaveTo\$DateTime $BaseFilename")
$Excel.Close()

# Send file to static recipients list.
Send-MailMessage -From $Sender -To $Recipients -Subject "$Date - Local Admin Accounts" -Attachments "$SaveTo\$DateTime $BaseFilename" -SMTP "$SMTP" -Body "The attached report ($DateTime $BaseFilename) lists the accounts that have local administrator access. This file has also been saved to:  $SaveTo\$DateTime $BaseFilename"

Clear
