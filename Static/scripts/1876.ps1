function Seach-LocalGroupMemberDomenNetwork() {
param(
$Domen,
$User
)

function Ping ($Name){ 
    $ping = new-object System.Net.NetworkInformation.Ping
    if ($ping.send($Name).Status -eq "Success") {$True}
    else {$False} 
	trap {Write-Verbose "&#1054;&#1096;&#1080;&#1073;&#1082;&#1072; &#1087;&#1080;&#1085;&#1075;&#1072;"; $False; continue}
}

[string[]]$Info
[string[]]$Computers

if ($User){$Connection = Get-Credential -Credential $User}

$Computers = Get-QADComputer -Service $Domen -OSName '*XP*','*Vista*','*7*' -SizeLimit 0 -ErrorAction SilentlyContinue | 
			 Select-Object name -ExpandProperty name

Foreach ($Computer in $Computers){
	$Alive = Ping $Computer
	if ($Alive -eq "True"){
		
		if ($Connection) {
			Trap {Write-Host "Error WMI $Computer";Continue}
			$GroupName = Get-WmiObject win32_group -ComputerName $Computer -Credential $Connection | 
						Where-Object {$_.SID -eq 'S-1-5-32-544'} | 
						Select-Object name -ExpandProperty name
		}
		else {
		Trap {Write-Host "Error WMI $Computer";Continue}
			$GroupName = Get-WmiObject win32_group -ComputerName $Computer | 
						Where-Object {$_.SID -eq 'S-1-5-32-544'} | 
						Select-Object name -ExpandProperty name
		}
		
		if ($GroupName){
			$Users = ([ADSI]"WinNT://$Computer/$GroupName").psbase.invoke("Members") | 
						% {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
			$Info += $Users | % {$_ | Select-Object @{e={$Computer};n='&#1050;&#1086;&#1084;&#1087;&#1100;&#1102;&#1090;&#1077;&#1088;'},@{e={$_};n='&#1051;&#1086;&#1075;&#1080;&#1085;'}}
		}
	}
}
$Info
}

