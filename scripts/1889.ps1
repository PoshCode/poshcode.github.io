function Deleted-Folders(){
param (
$Computer,
[String[]]$SeachFoldersDeleted
)

$Info = $null
$Disks = $null

trap {Write-Host "Error WmiObject $Computer";Continue}
$Disks += Get-WmiObject win32_logicaldisk -ComputerName $Computer | 
		  Where-Object {$_.Size -ne $null}

foreach ($Disk in $Disks){
	
	if ($Disk.Name -like "*:*") {
	$Disk = $Disk.Name.replace(":","$")
	}
	
	trap {Write-Host "Error ChildItem $Computer";Continue}
	$Info += Get-ChildItem "\\$Computer\$Disk\*" -recurse -ErrorAction SilentlyContinue
		
	if ($Info -ne $null){
		
		foreach ($Folder in $SeachFoldersDeleted){
			$Info | Where-Object {$_.Name -like $Folder} | 
					% {remove-item $_.fullname -Recurse -Force -ErrorAction SilentlyContinue}
		}
	}
}
}
