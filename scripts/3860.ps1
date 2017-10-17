PARAM(
	$location=$(throw "Make sure to specify a location for old machines to be imported")
)
$oldVM = Get-ChildItem "$location\*.xml"

foreach($vm in $oldVM)
{
	$vmGuid = [System.IO.Path]::GetFileNameWithoutExtension($vm.Name)
	Invoke-Command -ScriptBlock {cmd /c "Mklink `"C:\ProgramData\Microsoft\Windows\Hyper-V\Virtual Machines\$vmGuid.xml`" `"D:\VMConfig\Virtual Machines\$vmGuid.xml`""}
	Invoke-Command -ScriptBlock {cmd /c "Icacls `"C:\ProgramData\Microsoft\Windows\Hyper-V\Virtual Machines\$vmGuid.xml`" /grant `"NT VIRTUAL MACHINE\$vmGuid`":(F) /L"}
	Invoke-Command -ScriptBlock {cmd /c "Icacls $location /T /grant `"NT VIRTUAL MACHINE\$vmGuid`":(F)"}
}
