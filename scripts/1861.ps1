function Get-Constructor {
PARAM( [Type]$type )
$type.GetConstructors() | 
	Format-Table @{
		l="$($type.Name) Constructors"
		e={ "New-Object $($type.FullName) $(($_.GetParameters() | ForEach { "[{0}] `${1}" -f $($_.ToString() -split " ") }) -Join ", ")" }
	}
}

Set-Alias gctor Get-Constructor
