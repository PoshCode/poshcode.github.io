function Get-Constructor {
PARAM( [Type]$type )
$type.GetConstructors() | 
	Format-Table @{
		l="$($type.Name) Constructors"
		e={ ($_.GetParameters() | % { $_.ToString() }) -Join ", " }
	}
}

Set-Alias gctor Get-Constructor

