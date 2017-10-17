Function Is-Admin
{
	$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
	$role = [Security.Principal.WindowsBuiltInRole]::Administrator
	return $principal.IsInRole($role)
}

