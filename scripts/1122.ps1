#You Need Quest AD Powershell Plugin
#You Need VMWare VI Toolkit

$Null = Connect-VIServer Your-VM-Server-Here;

$Servers = New-Object System.Collections.ArrayList

$Null = Get-QADComputer -SearchRoot 'your.domain.com/Path/To/Server/OU' |  Select-Object -property Name | Format-Table -HideTableHeaders| Out-String -Stream | ForEach-Object{$Servers.Add($_.ToString().ToUpper())}
$Null = Get-VM | Select-Object -property Name | Format-Table -HideTableHeaders | Out-String -Stream | ForEach-Object{$Servers.Remove($_.ToString().ToUpper())}


foreach ($Server in $Servers | Sort-Object )
{
	ServiceTag = (Get-WmiObject Win32_BIOS -comp ($Server.ToString().Split(' '))[0]).SerialNumber;
	$Result = New-Object -TypeName psobject;
	$Result | Add-Member -MemberType NoteProperty -Name "Server Name" ($Server.ToString().Split(' '))[0];
	$Result | Add-Member -MemberType NoteProperty -Name "Service Tag" $ServiceTag;
	 
	Write-Output $Result;
	
	
}


