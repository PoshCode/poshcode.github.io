function New-SQLComputerLogin {
param(
	[Parameter(Mandatory=$True,Position=0)]
	[String]$SQLServer,
	[Parameter(Mandatory=$True,Position=1)]
	[String]$ComputerName,
	[Switch]$Force
)

## Import-Module QAD, SQLPS -DisableNameChecking

$Computer = Get-QADComputer $ComputerName
#$NTAccountName = $Computer.NTAccountName
#if(!$SID) {	$SID = $Computer.SID.ToString() }


invoke-sqlcmd -ServerInstance $SQLServer -Query "CREATE LOGIN [$($Computer.NTAccountName)] FROM WINDOWS" -ErrorVariable SqlError -ErrorAction SilentlyContinue
## If this principal already exists, fail, or clean it out and recreate it:
if($SqlError[0].Exception.Message.EndsWith("already exists.")) {
	if(!$Force) {
		Write-Error $SqlError[0].Exception
	} else {
		$ExistingAccount = 
			invoke-sqlcmd -ServerInstance $SQLServer -Query "select name, sid, create_date from sys.server_principals where type IN ('U','G')" | 
				add-member -membertype ScriptProperty SSDL { new-object security.principal.securityidentifier $this.SID, 0 } -passthru | 
				where-object {$_.SSDL -eq $Computer.SID}

		invoke-sqlcmd -ServerInstance $SQLServer -Query "DROP LOGIN [$($ExistingAccount.Name)]" -ErrorAction Stop

		invoke-sqlcmd -ServerInstance $SQLServer -Query "CREATE LOGIN [$($Computer.NTAccountName)] FROM WINDOWS"
	}
}
}
