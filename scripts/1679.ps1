# Report VMs created per month.
# Before you begin run Alan's "Who Created that VM?" script.
# http://www.virtu-al.net/2010/02/23/who-created-that-vm/
function Get-VMCreationReport {
	Get-VM | Group {
		if ($_.CustomFields["CreatedOn"] -as [DateTime] -ne $null) {
			"{0:Y}" -f [DateTime]$_.CustomFields["CreatedOn"]
		} else {
			"Unknown"
		}
	}
}

# To create a CSV of this stuff try:
# Get-VMCreationReport | select Count, Name, { $_.Group -as [String] } |
#	export-csv c:\report.csv -NoTypeInformation
