# Depends on Invoke-SQLCmd2 http://poshcode.org/2950
# Depends on Get-ADComputer http://poshcode.org/3011

function New-SqlComputerLogin {
#.Synopsis
#   Creates a Login on the specified SQL server for a computer account
#.Example
#	New-SqlComputerLogin -SQL DevDB2 -Computer BuildBox2 -Force
#
#	Specifying the Force parameter causes us to lookup the SID and remove a duplicate entry (in case your computer had an account before under another name).
[CmdletBinding()]
param(
	[Parameter(Mandatory=$true, Position=0)]
	[String]$SQLServer,
	
	[Parameter(ValueFromPipelineByPropertyName=$true, Position=1)]
	[String]$ComputerName,
	
	[Switch]$Force
)
process {
# Import-Module QAD, SQLPS -DisableNameChecking
$Computer = Get-ADComputer $ComputerName
#$NTAccountName = $Computer.NTAccountName
#if(!$SID) {	$SID = $Computer.SID.ToString() }


invoke-sqlcmd2 -ServerInstance $SQLServer -Query "CREATE LOGIN [$($Computer.NTAccountName)] FROM WINDOWS" -ErrorVariable SqlError -ErrorAction SilentlyContinue
## If this principal already exists, fail, or clean it out and recreate it:
if($SqlError[0].Exception.GetBaseException().Message.EndsWith("already exists.")) {
	if(!$Force) {
		Write-Error $SqlError[0].Exception.GetBaseException().Message
		$ExistingAccount = 
			invoke-sqlcmd2 -ServerInstance $SQLServer -Query "select name, sid from sys.server_principals where type IN ('U','G')" | 
				add-member -membertype ScriptProperty SSDL { new-object security.principal.securityidentifier $this.SID, 0 } -passthru | 
				where-object {$_.SSDL -eq $Computer.SID}

		Write-Warning "You need to drop [$($ExistingAccount.Name)] or run New-SqlComputerLogin again with -Force"
	} else {
		Write-Warning ($SqlError[0].Exception.GetBaseException().Message + " -- DROPping and reCREATEing")
		$ExistingAccount = 
			invoke-sqlcmd2 -ServerInstance $SQLServer -Query "select name, sid from sys.server_principals where type IN ('U','G')" | 
				add-member -membertype ScriptProperty SSDL { new-object security.principal.securityidentifier $this.SID, 0 } -passthru | 
				where-object {$_.SSDL -eq $Computer.SID}

		Write-Warning "Dropping [$($ExistingAccount.Name)] to create [$($Computer.NTAccountName)]"
		invoke-sqlcmd2 -ServerInstance $SQLServer -Query "DROP LOGIN [$($ExistingAccount.Name)]" -ErrorAction Stop

		invoke-sqlcmd2 -ServerInstance $SQLServer -Query "CREATE LOGIN [$($Computer.NTAccountName)] FROM WINDOWS"
		invoke-sqlcmd2 -ServerInstance $SQLServer -Query "select name, type_desc, default_database_name, create_date from sys.server_principals where name = '$($Computer.NTAccountName)'" 
	}
}
}
}
