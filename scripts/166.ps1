$compres = Read-Host -message "Enter a computer name."
$date = Get-WmiObject Win32_OperatingSystem -ComputerName $compres | foreach{$_.LastBootUpTime}
$RebootTime = [System.DateTime]::ParseExact($date.split('.')[0],'yyyyMMddHHmmss',$null) 
$RebootTime 
