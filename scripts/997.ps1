
#Global Hashtable to Control all Powershell Server Runspace
Set-Variable -name '__PSRUNSPACES__' -scope 'global' -value @{} -force

function global:New-PowerShellServerRunspace
{
	param(
		$Credential,
		$ErrorAction='Stop',
		[switch]$Force,
		$Password,
		$Port=22,
		$Server='127.0.0.1',
		$SSHAccept,
		$Timeout=30,
		$user
	)
	$ErrorActionPreference = $ErrorAction
	trap{
		Throw "Function New-PowerShellServerRunspace threw error $($error[0])"
	}
	if(($Credential -eq $null) -and  (($User -eq $null) -and ($Password -eq $null))){
		Throw "You Must Provide Authenication `n PSCredential or User and Password"
	}	
	if( ($global:__PSRUNSPACES__.Keys -contains "$Server") -and ($global:__PSRunspaces__["$Server"].RunspaceStateInfo -eq 'OPENED' ) )
	{
		Write-Output $global:__PSRUNSPACES__["$Server"]
		return
	}
	else
	{
		if($Force){
			if($Credential){
				$script:rs = & (Get-Command -commandType 'Cmdlet' -name 'New-PowerShellServerRunspace') -Server $Server -Credential $Credential -Port $Port -Force -ErrorAction $ErrorAction -Timeout $Timeout
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'Credential' -value $Credential -force
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'Port' -value $Port -force
				[scriptblock]$SB = { $This = New-PowerShellServerRunspace -Server $This.SSHServer -Credential $This.Credential -Port $This.Port -Force ; $This.RunspaceStateInfo = 'OPENED'}
				Add-Member -inputObject $script:rs -memberType ScriptMethod -name 'Reconnect' -value $SB -force
			}
			else{
				$script:rs = & (Get-Command -commandType 'Cmdlet' -name 'New-PowerShellServerRunspace') -Server $Server -User $User -Password $Password -Port $Port -Force -ErrorAction $ErrorAction -Timeout $Timeout
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'User' -value $User -force
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'Password' -value $Password -force
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'Port' -value $Port -force
				[scriptblock]$SB = { $This = New-PowerShellServerRunspace -Server $This.SSHServer -User $This.User -Password $This.Password -Port $This.Port -Force ; $This.RunspaceStateInfo = 'OPENED'}
				Add-Member -inputObject $script:rs -memberType ScriptMethod -name 'Reconnect' -value $SB -force
			}
		}
		elseif($SSHAccept){
			if($Credential){
				$script:rs = & (Get-Command -commandType 'Cmdlet' -name 'New-PowerShellServerRunspace') -Server $Server -Credential $Credential -Port $Port -SSHAccept $SSHAccept	-ErrorAction $ErrorAction -Timeout $Timeout
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'Credential' -value $Credential -force
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'Port' -value $Port -force
				[scriptblock]$SB = { $This = New-PowerShellServerRunspace -Server $This.SSHServer -Credential $This.Credential -Port $This.Port -Force ; $This.RunspaceStateInfo = 'OPENED'}
				Add-Member -inputObject $script:rs -memberType ScriptMethod -name 'Reconnect' -value $SB -force
			}
			else{
				$script:rs = & (Get-Command -commandType 'Cmdlet' -name 'New-PowerShellServerRunspace') -Server $Server -User $User -Password $Password -Port $Port -SSHAccept $SSHAccept	-ErrorAction $ErrorAction -Timeout $Timeout
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'User' -value $User -force
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'Password' -value $Password -force
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'Port' -value $Port -force
				[scriptblock]$SB = { $This = New-PowerShellServerRunspace -Server $This.SSHServer -User $This.User -Password $This.Password -Port $This.Port -Force ; $This.RunspaceStateInfo = 'OPENED'}
				Add-Member -inputObject $script:rs -memberType ScriptMethod -name 'Reconnect' -value $SB -force
			}
		}
		else{
			if($Credential){
				$script:rs = & (Get-Command -commandType 'Cmdlet' -name 'New-PowerShellServerRunspace') -Server $Server -Credential $Credential -Port $Port -ErrorAction $ErrorAction -Timeout $Timeout
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'Credential' -value $Credential -force
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'Port' -value $Port -force
				[scriptblock]$SB = { $This = New-PowerShellServerRunspace -Server $This.SSHServer -Credential $This.Credential -Port $This.Port -Force ; $This.RunspaceStateInfo = 'OPENED'}
				Add-Member -inputObject $script:rs -memberType ScriptMethod -name 'Reconnect' -value $SB -force
			}
			else{
				$script:rs = & (Get-Command -commandType 'Cmdlet' -name 'New-PowerShellServerRunspace') -Server $Server -User $User -Password $Password -Port $Port -ErrorAction $ErrorAction -Timeout $Timeout
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'User' -value $User -force
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'Password' -value $Password -force
				Add-Member -inputObject $script:rs -memberType NoteProperty -name 'Port' -value $Port -force
				[scriptblock]$SB = { $This = New-PowerShellServerRunspace -Server $This.SSHServer -User $This.User -Password $This.Password -Port $This.Port -Force ; $This.RunspaceStateInfo = 'OPENED'}
				Add-Member -inputObject $script:rs -memberType ScriptMethod -name 'Reconnect' -value $SB -force
			}
		}
		$global:__PSRUNSPACES__["$Server"] = $script:rs
		Write-Output $global:__PSRUNSPACES__["$Server"]
		return
	}
}

function global:Remove-PowerShellServerRunspace
{
	param(
		$SSHRunspace
	)
	if($SSHRunspace)
	{
		& (Get-Command -commandType 'Cmdlet' -name 'Remove-PowerShellServerRunspace') -SSHRunspace $SSHRunspace
		if( $global:__PSRUNSPACES__.Keys -contains $SSHRunspace.SSHServer )
		{
			$global:__PSRUNSPACES__.Remove($SSHRunspace.SSHServer)
		}
	}
	elseif( $global:__FPRUNSPACES__.Count -gt 0 )
	{
		$global:__FPRUNSPACES__ | Foreach-Object { 
			& (Get-Command -commandType 'Cmdlet' -name 'Remove-PowerShellServerRunspace') -SSHRunspace $_
		}
		$global:__PSRUNSPACES__.Clear()
	}
}
