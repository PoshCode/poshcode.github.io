#.Synopsis
#  Convert Bounce to X500
#.Description
#  Convert URL Encoded address in a Bounce message to an X500 address
#  that can be added as an alias to the mail-enabled object
#.Parameter bounceAddress
#  URL Encoded bounce message address#
#.Example
#  Convert-BounceToX500 "IMCEAEX-_O=CONTOSO_OU=First+20Administrative+20Group_cn=Recipients_cn=john+5Fjacob+2Esmith@contoso.com"
#.Example
#  "IMCEAEX-_O=CONTOSO_OU=First+20Administrative+20Group_cn=Recipients_cn=john+5Fjacob+2Esmith@contoso.com"|Convert-BounceToX500

[CmdletBinding()]
PARAM (
	[Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$bounceAddress
)
BEGIN
{
}
PROCESS
{
	if($_) {$bounceAddress = $_}
	$bounceAddress = $bounceAddress -replace "^IMCEAEX-","" -replace "/","\/" -replace "_","/" -replace "@.*$",""
	# The following replaces all "+xx" strings with their ASCII equivalent
	While ($bounceAddress -match "\+([0-9a-f][0-9a-f])")
	{
		$bounceAddress=$bounceAddress -replace ("\$($matches[0])",[char][byte][convert]::ToInt16($matches[1],16))
	}
	$bounceAddress
}
