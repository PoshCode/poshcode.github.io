$insParm = '/s /v"/qn /norestart"' 
$updList = get-cluster -name $YouClusterNameHere | get-vm |
	where-object {$_.powerstate -eq "PoweredON"} |
		foreach-object { get-view $_.ID } |
			where { $_.guest.toolsstatus -match "toolsOld" } 
foreach ($uVM in $updList) 
{
	$uVM.name 
	$uVM.UpgradeTools_Task($insParm) 
	#Wait 30 seconds before starting another update task 
	Start-sleep -s 30 
}
