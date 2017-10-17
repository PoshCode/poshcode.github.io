Function Test-GroupMembership {
	Param($user,$group)
	Get-QADUser $user | select memberof | %{
		$result = $false
		foreach ($i in $_.memberof) {
			if ((Get-QADGroup $i).name -match $group){
				$result = $true
				break
			}
		}
		$obj = "" | select Name,Group,IsMember
		$obj.Name = $user
		$obj.Group = $group
		$obj.IsMember = $result
		write $obj
	}
}
