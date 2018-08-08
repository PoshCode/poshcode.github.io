# Add the Exchange Setup Snapin
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Setup
# Get the performace counter definitions from within the Exchange setup directory and recreate the counters
Get-ChildItem "$exInstall\Setup\Perf" | Where-Object {$_.Name -match ".xml"} | Foreach {New-PerfCounters -DefinitionFileName $_.FullName}
