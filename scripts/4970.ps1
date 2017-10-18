function Get-LocalGroupMembers {
	param($groupname,$computer)

	$pattern = "'\\\\$computer\\root\\cimv2:Win32_Group.Domain=`"$computer`",Name=`"$groupname`"'"
	$groupusers = gwmi Win32_GroupUser -ComputerName $computer -filter "GroupComponent = $pattern"

	# Now extract the usernames.
	foreach ($user in $groupusers) {
		if ($user.PartComponent -match 'Name="([^"]+)') {
			Write-Output $matches[1]
		}
	}
}

# Updated to filter the query to only the group looked for on the local computer
# in the previous version in a domain environment it would end up querying the DC
# returning all users and groups and piping them to Where, causing a LONG delay
# Use it like this.
# Get-GroupMembers Administrators Computer

