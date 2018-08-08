# This is to remove the Hidden folder attribute and delete the autorun.inf and x.mpeg due to changeup virus!
# 4-3-2013 John R Remillard
# You need the exact root folder path to unhide and delete the proper files and folders.
#$Pth = Read-Host "Enter full path to unhide"
$Lst = Get-Content c:\Shares.txt
foreach ($Pth in $Lst)
{
$File1 = Test-Path $Pth"autorun.inf"
if ($File1 -eq "True") 
{
 	$Pth | Out-File c:\changup_virus.txt -append
    Remove-item -Path $Pth"autorun.inf" -Force
	Remove-item -Path $Pth"x.mpeg" -Force
	get-childitem $pth -directory -hidden | foreach {$_.Attributes="Normal"}
}
}
