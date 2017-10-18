$pc = New-Object Diagnostics.PerformanceCounter("System", "System Up Time", $true)
[void]$pc.NextValue()
[TimeSpan]::FromSeconds($pc.NextValue()) | select Days, Hours, Minutes, Seconds | ft -a
