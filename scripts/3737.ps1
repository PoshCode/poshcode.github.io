Param (
  [string[]]$Computers=$env:ComputerName,
  [string[]] $Paths = @("C:\Windows","C:\Windows\system32"),
  [string[]] $FileNames = @("fsb.tmp","fsb.stb","notpad.exe")
)
$Global:objOut = @()


Function FindFiles ($Computer, $Filter){
try{
	$Files = Gwmi -namespace "root\CIMV2" -computername $Computer -class CIM_DataFile -filter "Name = '$Filter'"
	if ($Files){
		foreach ($File in $Files){
			$Result = New-Object PSObject -Property @{
				Host = $Computer
				Path = $File.Name
				FileSize = "$([math]::round($File.FileSize/1KB)) KB"
				Modified = [System.Management.ManagementDateTimeconverter]::ToDateTime($File.LastModified).ToShortDateString()
				InUse = ([System.Convert]::ToBoolean($File.InUseCount))
				LastUsed = [System.Management.ManagementDateTimeconverter]::ToDateTime($File.LastAccessed).ToShortDateString()
				}
			$Global:objOut += $Result
			}
		}
	}
catch{
	$continue = $False
	Write-Host $($error[0] | fl *)
	}
}
foreach ($Computer in $Computers){
	if (Test-Connection -ComputerName $Computer -Count 1 -Quiet){
		foreach ($Path in $Paths){
			foreach ($FileName in $FileNames){
				# WMI needs double quotes in a path
				$Filter = "$Path\$FileName" -replace '\\','\\'
				FindFiles $Computer $Filter
				}
			}
		}
	else {
		Write-Host "$Computer cannot be reached"
		}
	}
$Global:objOut

