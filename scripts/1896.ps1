param (
$Computer,
[String[]]$ObjectsDeleted
)

$Info = $null
$Disks = $null

trap {Write-Host "Error WmiObject $Computer";Continue}
$Disks += Get-WmiObject win32_logicaldisk -ComputerName $Computer | 
		  Where-Object {$_.Size -ne $null}

foreach ($Disk in $Disks){
	
	if ($Disk.Name -like "*:*") {
	$Disk = $Disk.Name.Replace(":","$")
	}
	
	trap {Write-Host "Error ChildItem $Computer";Continue}
	$Info += Get-ChildItem "\\$Computer\$Disk\*" -Recurse -ErrorAction SilentlyContinue
		
	if ($Info){
		
		foreach ($Object in $ObjectsDeleted){
			$Info | Where-Object {$_.Name -like $Object} | 
					% {remove-item $_.fullname -Recurse -Force -ErrorAction SilentlyContinue}
		}
	}
}
