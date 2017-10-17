
function Add-Argument
{
	[CmdletBinding()]
	[OutputType([string])]
	PARAM(
		[Parameter(Mandatory,Position=0,ValueFromPipelineByPropertyName)]
		[ValidateNotNullOrEmpty]
		[string]$Name,

		[Parameter(Mandatory,Position=1,ValueFromPipelineByPropertyName)]
		[ValidateNotNullOrEmpty]
		[string]$Value
	)

	BEGIN
	{
		$result = "/{0}='{1}' -f $Name $Value		
		Write-Output $result
	}

}

### MED OVANSTÅENDE - LÖSNING 1 - sätt värden i scriptet
########################################################################
$processName = (Resolve-Path "setup.exe")
$argumentList = @()

$argumentList += Add-Argument "SQLSVCACCOUNT" "AnAccount"
$argumentList += Add-Argument "SQLPASSWORD" "SecretStuff"
$argumentList += Add-Argument "SQLCOLLATION" "SomeCollationId"

Start-Process $processName -ArgumentList $argumentList

### MED OVANSTÅENDE - LÖSNING 2 - spara värden i csv fil enligt nedan:
### Name,Value
### SQLSVCACCOUNT,AnAccount
### SQLPASSWORD, SecretStuff
### SQLCOLLATION, SomeCollationId
########################################################################

$processName = (Resolve-Path "setup.exe")
Start-Process $processName -ArgumentList (Import-CSV .\MyARgumentFile.csv | Add-Argument)


