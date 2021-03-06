# basic disk report tool that generates an excel report. 
# usually you should just need to edit the line indicated below. 
$erroractionpreference = “SilentlyContinue” 
$a = New-Object -comobject Excel.Application 
$a.visible = $True

$b = $a.Workbooks.Add() 
$c = $b.Worksheets.Item(1)

$c.Cells.Item(1,1) = “Machine Name” 
$c.Cells.Item(1,2) = “Drive” 
$c.Cells.Item(1,3) = “Total size (GB)” 
$c.Cells.Item(1,4) = “Free Space (GB)” 
$c.Cells.Item(1,5) = “Free Space (%)” 
$c.cells.item(1,6) = "Name "

$d = $c.UsedRange 
$d.Interior.ColorIndex = 19 
$d.Font.ColorIndex = 11 
$d.Font.Bold = $True 
$d.EntireColumn.AutoFit()

$intRow = 2
# edit the file path to where your list of servers is found
$colComputers = get-content "C:\Users\~206425494.TFAYD\Desktop\Servers.txt"
foreach ($strComputer in $colComputers) 
{ 
$colDisks = get-wmiobject win32_volume -computername $strComputer
foreach ($objdisk in $colDisks) 
{ 
$c.Cells.Item($intRow, 1) = $strComputer.ToUpper() 
$c.Cells.Item($intRow, 2) = $objDisk.Label 
$c.Cells.Item($intRow, 3) = “{0:N0}” -f ($objDisk.Capacity/1GB) 
$c.Cells.Item($intRow, 4) = “{0:N0}” -f ($objDisk.FreeSpace/1GB) 
$c.Cells.Item($intRow, 5) = “{0:P0}” -f ([double]$objDisk.FreeSpace/[double]$objDisk.Capacity) 
$c.cells.item($introw, 6) = $objdisk.volumename

$intRow = $intRow + 1 
} 
}
$d.EntireColumn.AutoFit()
cls
