function Get-User($user)
{
	# this function should be passed the CN of the user to be returned
	$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() 
	$root = [ADSI] "LDAP://$($dom.Name)"
	$searcher = New-Object System.DirectoryServices.DirectorySearcher $root
	$searcher.filter = "(&(objectCategory=person)(objectClass=user)(cn=$user))"
	$user = $searcher.FindOne()
	[System.Collections.Arraylist]$names = $user.Properties.PropertyNames
	[System.Collections.Arraylist]$props = $user.Properties.Values
	$userobj = New-Object System.Object
	for ($i = 0; $i -lt $names.Count)
		{
			$userobj | Add-Member -type NoteProperty -Name $($names[$i]) -Value $($props[$i])
			$i++
		}
	$userobj.pwdlastset = [System.DateTime]::FromFileTime($userobj.pwdlastset)
	$userobj.lastlogontimestamp = [System.DateTime]::FromFileTime($userobj.lastlogontimestamp)
	return $userobj
}
