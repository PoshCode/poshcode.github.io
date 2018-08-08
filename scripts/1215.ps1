function Get-StringRange ( $Start, $End ) {
	[char[]]( [int][char]$Start..[int][char]$End )
}
