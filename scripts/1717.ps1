<#
	.SYNOPSIS
		Quick way to see whether the object exists in AD.

	.DESCRIPTION
		Returns $true if at least one object matching the criteria exists and false otherwise.

	.PARAMETER  Identity
		Specify the DN, SID, GUID, UPN or Domain\Name of the directory object you want to find

	.EXAMPLE
		PS C:\> Test-QADObject dsotniko

	.EXAMPLE
		PS C:\> Test-QADObject 5ae7197e-cac3-42bf-9541-e06fa33ed965

	.EXAMPLE
		PS C:\> Test-QADObject 'OU=demo,DC=quest,DC=local'

 .INPUTS
		System.String,System.String[]

	.OUTPUTS
		System.Boolean

	.NOTES
		(c) Dmitry Sotnikov, http://dmitrysotnikov.wordpress.com
  Requires Quest AD cmdlets which are a free download from
  http://www.quest.com/activeroles-server/arms.aspx

	.LINK
		Get-QADObject

#>
function Test-QADObject {
	[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true)]
		[System.String]
		$Identity
	)
  (Get-QADObject $Identity -DontUseDefaultIncludedProperties `
    -WarningAction SilentlyContinue -ErrorAction SilentlyContinue `
    -SizeLimit 1) -ne $null
}

Set-Alias -Name Test-QADPath -Value Test-QADObject 
