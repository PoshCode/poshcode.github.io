$strComputer = "ComputerName"
$Ports = get-wmiobject -class "win32_tcpipprinterport" -namespace "root\CIMV2" -computername $strComputer -EnableAllPrivileges
$Printers = get-wmiobject -class "Win32_Printer" -namespace "root\CIMV2" -computername $strComputer -EnableAllPrivileges
$ports | Select-Object Name,Hostaddress | Set-Variable port
$Printers | Select-Object Name,PortName,DriverName,location,Description | Set-Variable print
$num = 0
$hash = @{}
do {
$hash.Add($port[$num].name, $port[$num].hostaddress)
$num = $num + 1
} until ($num -eq $ports.Count)

# Creates Table
$table = New-Object system.Data.DataTable “$PrinterInfo”
$colName = New-Object system.Data.DataColumn PrinterName,([string])
$colIP = New-Object system.Data.DataColumn IP,([string])
$colDrive = New-Object system.Data.DataColumn DriverName,([string])
$colLoc = New-Object system.Data.DataColumn Location,([string])
$colDesc = New-Object system.Data.DataColumn Description,([string])
$table.columns.add($colName)
$table.columns.add($colIP)
$table.columns.add($colDrive)
$table.columns.add($colLoc)
$table.columns.add($colDesc)
$num = 0
Do {
$row = $table.NewRow()
$row.PrinterName = $printers[$num].name
$row.IP = $hash.get_item($printers[$num].PortName)
$row.DriverName = $printers[$num].drivername
$row.Location = $printers[$num].Location[$num]
$row.Description = $printers[$num].Description
$table.Rows.Add($row)
$num = $num + 1
} until ($num -eq $printers.Count)

$table | Select-Object PrinterName,IP,DriverName,Location,Description | Export-Csv C:\Printers.csv -NoType
