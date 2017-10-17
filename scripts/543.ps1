# Sets local account passwords on one or more computers
# usage [computerName1,computerName2,... | ] ./Set-LocalPassword.ps1 [-user] <userName> [-password] <password> [[-computers] computerName1,computerName2,...]

param(
	[string] $User
	, [string] $Password
    , [string[]] $ComputerNames = @()
)

$ComputerNames += @($input)

if (! $ComputerNames)
{
    $ComputerNames = $env:computername
}


function ChangePassword ([string] $ChangeComputer, [string] $ChangeUser, [string] $ChangePassword) {
	"*** Setting password for $ChangeComputer/$ChangeUser"
	& {
	$ErrorActionPreference="silentlycontinue"
	([ADSI] "WinNT://$computer/$user").SetPassword($password)
	if ($?) { " Success" }
	else { " Failed: $($error[0])" }
	}

}

function ShowUsage {
@'
usage [computerName1,computerName2,... | ] ./Set-LocalPassword.ps1 [-user] <userName> [-password] <password> [[-computers] computerName1,computerName2,...]
'@
}


if ($user -match '^$|-\?|/\?|-help' -or ! $password) { ShowUsage; break; }
ForEach ($computer in $ComputerNames) { 
	ChangePassword $computer $user $password 
}
