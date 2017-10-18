$DCs = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).DomainControllers
$DCs | % { if ($_.Roles -ne '') {
		"Server $_ has roles:"
		""
		foreach ($role in $_.roles) {
			$role.tostring().padleft($role.tostring().length + 10)
		}
		""
	}
}
