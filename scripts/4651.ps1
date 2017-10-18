Import-Module Activedirectory

#Lower Case!!
$oldserver = "hostname"

#Lower Case!!
$newserver = "hostname"

$users = get-aduser -filter * -properties homedirectory,profilepath

foreach ($user in $users) {
	$name = $user.name
	$DN = $user.distinguishedname
	$profilepath = $user.profilepath
	$homedirectory = $user.homedirectory

	if ($profilepath -like "*$oldserver*")
		{
#Add -whatif to next line before running the script to see what would happen
		Set-Aduser $DN -profilepath $profilepath.ToLower().replace($oldserver,$newserver)
		}
	else	{
		Write-Host -foregroundcolor RED "User $name does not have roaming profile on $oldserver"
		}

	if ($homedirectory -like "*$oldserver*")
		{
#Add -whatif to next line before running the script to see what would happen
		Set-Aduser $DN -homedirectory $homedirectory.ToLower().replace($oldserver,$newserver)
		}
	else	{
		Write-Host -foregroundcolor RED "User $name does not have a Home directory on $oldserver"
		}
}

