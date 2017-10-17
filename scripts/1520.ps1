# Need the Quest ActiveRoles cmdlets for this one.
Add-PSSnapin Quest.ActiveRoles* -ea SilentlyContinue

function Get-Groups {
	param($principal)

	# Start with this principal's base set of groups.
	Write-Verbose "Checking principal $principal"
	$groups = Get-QADUser $principal | Get-QADMemberOf

	# Groups can be members of groups, so iterate until the list size remains fixed.
	do {
		$startLength = $groups.length
		Write-Verbose ("Start length " + $startLength)
		$groups += $groups | Get-QADMemberOf
		$groups = $groups | Sort -Unique
		$endLength = $groups.length
		Write-Verbose ("End length " + $endLength)
	} while ($endLength -ne $startLength)

	Write-Output $groups
}

# Get the resultant privileges that a user has for a given object.
function Get-ResultantPrivileges {
	param($principal, $viobject)

	# Use the NT Account name.
	$account = (Get-QADUser $principal).NTAccountName
	if ($account -eq $null) {
		throw "$principal not found, please check your spelling."
	}

	# Get the groups for this user.
	$groups = Get-Groups -principal $account
	$groupNames = $groups | Foreach { $_.Name }

	# Get the full permission set for this object.
	$perms = $viobject | Get-VIPermission

	# Determine the list of roles that apply to this principal.
	$relevantPerms = $perms | Where {
		(($_.IsGroup -eq $true) -and ($groupNames -contains $_.Principal)) -or
		($_.Principal -eq $account)
	}

	# Retrieve all these roles.
	$roleNames = $relevantPerms | Foreach { $_.Role } | Sort -Unique
	Write-Verbose "Rolenames are $roleNames"
	$roleObjects = Get-VIRole $roleNames
	$roleCount = ($roleObjects | Measure-Object).Count

	# The resultant set is the intersection of the privileges within the role.
	$roleObjects | Foreach { $_.PrivilegeList } | Group |
		Where { $_.Count -eq $roleCount } |
		Select Name
}

# Example:
# Get-ResultantPrivileges -principal "VMWORLD\cshanklin" -viobject (Get-VM OpenFiler)
