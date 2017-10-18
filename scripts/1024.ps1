$excel = New-Object -comobject Excel.Application
$excel.visible = $False #Change to True to see the excel build
$wbook = $excel.Workbooks.Add()
$wsheet = $wbook.Worksheets.Item(1)
$wsheet.Cells.Item(1,1) = "Date"
$wsheet.Cells.Item(1,2) = "Server"
$wsheet.Cells.Item(1,3) = "NETID"
$wsheet.Cells.Item(1,4) = "Description"
$wsheet.Cells.Item(1,5) = "MAC"
$wsheet.Cells.Item(1,6) = "IP"
$wsheet.Cells.Item(1,7) = "DHCPEnabled"
$wsheet.Cells.Item(1,8) = "DHCPServer"
$wsheet.Cells.Item(1,9) = "DNSServerSearchOrder"
$wsheet.Cells.Item(1,10) = "WINSPrimaryServer"
$wsheet.Cells.Item(1,11) = "WINSSecondaryServer"
$wsheet.Cells.Item(1,12) = "DomainDNSRegistrationEnabled"
$wsheet.Cells.Item(1,13) = "FullDNSRegistrationEnabled"
$wsheet.Cells.Item(1,14) = "WINSEnableLMHostsLookup"
$range = $wsheet.UsedRange
$range.Interior.ColorIndex = 19
$range.Font.ColorIndex = 11
$range.Font.Bold = $True
$iRow = 2
$AllAdapters = @("")
$InputFile = "C:\Scripts\Servers.txt"
$Servers = Get-Content $InputFile
ForEach($Server in $Servers)
{
$Adapters = Get-Wmiobject Win32_NetworkAdapterConfiguration -Computername `
$Server | Where-Object{$_.IPEnabled -eq $True}
ForEach($Adapter In $Adapters)
{
[String]$DNSServers = ""
$Adapters2 = Get-Wmiobject Win32_NetworkAdapter -Computername $Server `
| Where-Object{$_.Caption -eq $Adapter.Caption}
[String]$NetID = $Adapters2.NetConnectionID
If($Adapter.DNSServerSearchOrder -ne $Null){ForEach($Address In `
$Adapter.DNSServerSearchOrder){$DNSServers += "[" + $Address + "]"}}
$wsheet.Cells.Item($iRow,1) = Get-Date
$wsheet.Cells.Item($iRow,2) = $Server
$wsheet.Cells.Item($iRow,3) = $NETID
$wsheet.Cells.Item($iRow,4) = $Adapter.Description
$wsheet.Cells.Item($iRow,5) = $Adapter.MACAddress
$wsheet.Cells.Item($iRow,6) = $Adapter.IPAddress
$wsheet.Cells.Item($iRow,7) = $Adapter.DHCPEnabled
$wsheet.Cells.Item($iRow,8) = $Adapter.DHCPServer
$wsheet.Cells.Item($iRow,9) = $DNSServers
$wsheet.Cells.Item($iRow,10) = $Adapter.WINSPrimaryServer
$wsheet.Cells.Item($iRow,11) = $Adapter.WINSSecondaryServer
$wsheet.Cells.Item($iRow,12) = $Adapter.DomainDNSRegistrationEnabled
$wsheet.Cells.Item($iRow,13) = $Adapter.FullDNSRegistrationEnabled
$wsheet.Cells.Item($iRow,14) = $Adapter.WINSEnableLMHostsLookup
$iRow = $iRow + 1
}
}
$range.EntireColumn.AutoFilter()
$range.EntireColumn.AutoFit()
$excel.ActiveWorkbook.SaveAs("C:\Scripts\NetworkScan.xls")
$excel.ActiveWorkbook.Close
$excel.Application.Quit
