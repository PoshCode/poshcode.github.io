param (
    [Parameter(Mandatory=$true)]
        [string]$OldPrintServer,
    [Parameter(Mandatory=$true)]
        [string]$NewPrintServer
)

#$ErrorActionPreference = 'SilentlyContinue'
$Printers = Get-WmiObject -Class Win32_Printer | where { $_.Network -eq $true }

foreach ($Printer in $Printers) {
    if ($Printer.SystemName -eq "\\$OldPrintServer") {            
        $ShareName = $Printer.ShareName
        $Name = $Printer.Name -replace $OldPrintServer, $NewPrintServer
        (New-Object -ComObject WScript.Network).AddWindowsPrinterConnection("\\$NewPrintServer\$ShareName") | Out-Null

        if ($Printer.Default -eq $true) {
            (Get-WmiObject -Class Win32_Printer | where { $_.Name -eq $Name}).SetDefaultPrinter() | Out-Null
        }

        $Printer.Delete() | Out-Null
    }
}
