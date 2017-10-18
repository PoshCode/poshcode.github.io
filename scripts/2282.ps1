$a="<style>"
$a=$a+"BODY{background-color :#FFFFF}"
$a=$a+"TABLE{Border-width:thin;border-style: solid;border-color:Black;border-collapse: collapse;}"
$a=$a+"TH{border-width: 0px;padding: 0px;border-style: solid;border-color: black;background-color: ThreeDShadow}"
$a=$a+"TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color: Transparent}"
$a=$a+"</style>"
$log = Get-EventLog -LogName "Security" -Newest 20
$log = $log | ConvertTo-Html -Property EventID,Category,EntryType,UserName,TimeGenerated,Message -head $a -body "<H2>Restricted Folder Audit Log</H2>" 
$log | Out-File C:\PowerShellLog.html -Force
