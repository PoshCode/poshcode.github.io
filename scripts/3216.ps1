gci 'c:\test\' -Recurse | % { Rename-Item $_.FullName $($_.Name -replace
	'[^\w\.]','') }
