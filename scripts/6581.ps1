function Get-LocalGroupMembers {
	param($groupname)

	$pattern = "*Name=`"$groupname`""
	$groupusers = gwmi Win32_GroupUser | Where { $_.GroupComponent -like $pattern }

	# Now extract the usernames.
	foreach ($user in $groupusers) {
		if ($user.PartComponent -match 'Name="([^"]+)') {
			Write-Output $matches[1]
		}
	}
}

# Use it like this.
# Get-GroupMembers Administrators
