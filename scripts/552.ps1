# ==============================================================================================
#  
# NAME: ServicePWChgReset.ps1
# 
# AUTHOR: Saehrig, Steven
# DATE  : 8/26/2008
@@# Requires - Quest ActiveRoles Snapin
@@# COMMENT: Please read comments on each section! 
# 1st - Search Domain computers for matching name and import into array. 
# 2nd - Export matching hosts from array to text file. (comment out after text file created)
# 3rd - Create CSV file of all Matching Critera with full service detail. ( so you have record of modified 
# services)
# 4th - Create text file of all matching services with limited info
# 5th - Change password on matching services
# 6th - Restart services if running if not running skip restart. (with console feedback)
#
# I would like to Thank Halr9000 and glnsize from powershellcomunity.org for there guidance during this
# script creation. I would not have been able to complete this without them and i would have been spending
# alot of time manually updating every service. Granted if they actually wrote this it would be much nicer :).
# But hey everyone has to start somewhere.
# ==============================================================================================

#discover Servers for Host.txt file
function func_Forest()
{
[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Domains | ForEach-Object {
	Get-QADComputer -Service $_.Name -SizeLimit 0 -ErrorAction SilentlyContinue `
		| Add-Member -Name 'DomainName' -MemberType NoteProperty -Value $_.Name -PassThru
}
}

#initialize Array for Output
$Array = @()
#This should be run once to fill the host file then commented out.
#Fill Array
func_forest | where { $_.Name  -like  'jxr*' } | Sort-Object -property "Name" |? { $array += $_.name}
$file = $array | Out-File -FilePath c:\txt\host.txt -Append


#Variables
$StartName = "username"
$csvlocation = "c:\txt\service.csv"
$txtlocation = "c:\txt\service.txt"
$computer = gc c:\txt\host.txt
$password = "password"
$service = gwmi -Class Win32_Service -namespace root\CIMV2 -ComputerName $computer | Where-Object {$_.StartName -match $startname}                   

#exports discovered services for documentation of modified services
$service | Export-Csv $csvlocation

#Function Declarations
function exporttxt { #This function exports the services to a text file in limited data fields.
	foreach ($i in $service) {
			($i | FT systemname, Displayname, State, Startname, Status | Out-File -Append -FilePath $txtlocation )
	}
}

function changepw { #This function will change the password to the variable assigned above.
	foreach ($i in $service) {
            (Write-Host -ForegroundColor "Yellow" "Changing password on" $i.SystemName "Service Name"$i.Name) 
			($i.Change($Null,$Null,$Null,$Null,$Null,$Null,$Null,$password))
			(Write-Host -ForegroundColor "green" "Password Successfully Changed on" $i.SystemName "Service Name"$i.Name) 
	}
}		

function restartsvc { #This function will restart the service for the new password to take effect.
$s = gwmi -Class Win32_Service -namespace root\CIMV2 -ComputerName $computer | Where-Object {$_.StartName -match $startname}
 	foreach ($i in $s) {
			if ($i.State -eq "running") {
				Write-Host -ForegroundColor "Yellow" "Service name" $i.SystemName "Service name"$i.Name "is" $i.state 
					$i.StopService()
					Sleep -Seconds 20 #allow time for service to stop.
					$b = gwmi -Class Win32_Service -namespace root\CIMV2 -ComputerName $computer | Where-Object {$_.StartName -match $startname}
						Write-Host -ForegroundColor "RED" "Service name" $b.SystemName "Service name" $b.Name "is" $b.state 
					$i.StartService()
				    $c = gwmi -Class Win32_Service -namespace root\CIMV2 -ComputerName $computer | Where-Object {$_.StartName -match $startname}
					Write-Host -ForegroundColor "Green" "Server name" $c.SystemName  "Service name" $c.Name "is" $c.state }
				
			elseif ($i.State -eq "Stopped") {
				Write-Host -ForegroundColor "RED" "Service name" $i.SystemName "Service name" $i.Name $i.state "Service will not be Started"  }
	}
}


#Execute
exporttxt
changepw | out-null
restartsvc | out-null
