# Type long (64-bit integer) is necessary because the WMI class state the capacity in byte --> might be too long for int32 ;-)
[long]$memory = 0

# Get the WMI class Win32_PhysicalMemory and total the capacity of all installed memory modules
Get-WmiObject -Class Win32_PhysicalMemory | ForEach-Object -Process { $memory += $_.Capacity }

# Display the output in Gigabyte
$memory / 1GB
