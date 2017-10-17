#Notes
#1. x86 properites will be empty for x86 machines as this property only pertains x64 machines which have both x64 and x86 shells.
#2. If policy registry key is not present then restricted is the effective setting

param($computerName=$env:computerName)

$reg = Get-WmiObject -List -Namespace root\default -ComputerName $ComputerName | Where-Object {$_.Name -eq "StdRegProv"}

new-object psobject -property @{
ComputerName=$ComputerName;
Path=($reg.GetStringValue(2147483650,"SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell","Path")).sValue;
Policy=($reg.GetStringValue(2147483650,"SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell","ExecutionPolicy")).sValue;
x86Path=($reg.GetStringValue(2147483650,"SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell","Path")).sValue
x86Policy=($reg.GetStringValue(2147483650,"SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell","ExecutionPolicy")).sValue
}
