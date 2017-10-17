## Works great for a..f or g..a
## BUT WEIRD for Z..a or A..a or anything non-latin
function Get-CharRange ( [char]$Start, [char]$End ) {
	[char[]]($Start..$End)
}

## Cleaner output. Try Get-LetterRange A z  vs. Get-CharRange A z
## And international. ## Get-LetterRange 0x0370 0x03FF Greek
## You just specify the character set by name, anything from Arabic and Armenian,
## Bengali, Cherokee, Cyrillic, to Greek, Hebrew, Mongolian, and so on.
## http://msdn.microsoft.com/en-us/library/20bw873z.aspx
function Get-LetterRange ( [char]$Start, [char]$End, [string]$charset = "BasicLatin" ) {
 [char[]]($Start..$End) | Where { $_ -match "(?=\p{Is$charset})\p{L}" }
}
