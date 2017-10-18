add-bulk-printers.ps1
$printers = import-csv "C:\temp\printers.csv"
$newprintserver = "fdqn"

function CreatePrinterPort 
    {
        $server = $args[0] 
        $port = ([WMICLASS]"\\$newprintserver\ROOT\cimv2:Win32_TCPIPPrinterPort").createInstance()
        $port.Name = $args[1]
        $port.SNMPEnabled = $false
        $port.Protocol = 1 
        $port.HostAddress = $args[2]
        $port.Put() 
    }

foreach ($printer in $printers)
    {
        CreatePrinterPort $printer.Printserver $printer.Portname $printer.IPAddress
        Add-Printer -Name $printer.Printername -ShareName $printer.Sharename -computername $newprintserver -drivername $printer.Driver -PortName $printer.Portname -Location $printer.Location -Comment $printer.Comment -Published:$false -Shared:$True
        write-host -ForegroundColor White $printer.Printername "has been added to $newprintserver"  
    }

export-printers.ps1
$printserver = "fqdn" 
Get-WMIObject -class Win32_Printer -computer $printserver | Select Name,DriverName,PortName,ShareName,Comment | Export-CSV -path 'C:\temp\printers.csv' -NoTypeInformation

CSV Required Headers
Printserver,Driver,PortName,IPAddress,Sharename,Location,Comment,Printername
