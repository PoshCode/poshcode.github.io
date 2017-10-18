#Jason Ochoa 9/16/09
#Set up NaServerObject
$null = [reflection.assembly]::loadfile('C:\DotNet\ManageOntap.dll')
$Toaster1 = new-Object netapp.manage.naserver('Toaster1',1,0)
$Toaster1.setadminuser("admin",'password')


#-------------------functions to be remade
function global:Get-DF-s ($NaServer){#this data can be gathered directly from the volume-info package
	$NaElement = New-Object NetApp.Manage.NaElement(”system-cli”)
	$arg = New-Object NetApp.Manage.NaElement(”args”)
	$arg.AddNewChild(’arg’,'df’)
	$arg.AddNewChild(’arg’,'-s’)
	$NaElement.AddChildElement($arg)
	$results= $NaServer.InvokeElem($naelement).GetChildContent(”cli-output”)
	$results = $results.Split("`n")
	
	$ResultsObj = $results| ?{$_ -match "vol"}| %{$null = $_ -match "(?<FileSystem>(\S+))\s+(?<used>(\d+))\s+(?<saved>(\d+))\s+(?<PercentSave>(\d+))"; 
						$myobj = "" | Select-Object filesystem, usedGB, savedGB, percentsave;
						$myobj.filesystem = $matches.Filesystem;
						$myobj.usedGB = [Math]::Round([double]$matches.used /1mb, 2);
						$myobj.savedGB = [Math]::Round([double]$matches.saved /1mb, 2);
						$myobj.percentsave = [int]$matches.percentsave; 
						,$myobj}
	,($ResultsObj| Sort-Object filesystem)
}
#------------------------------sis functions
function global:Get-SIS-Status ($NaServer){
$naelement = New-Object netapp.manage.naelement("sis-status")
$NaElement.AddNewChild('verbose','true')
$Output = ([xml]($NaServer.invokeelem($naelement)).tostring()).results.'sis-object'.'dense-status'
$Output =  $output | Add-Member -MemberType NoteProperty -Name "StartTime" -Value $null -PassThru |
					 Add-Member -MemberType NoteProperty -Name "Duration" -Value $null -PassThru 
$Output|  %{$_.Duration =(((get-date -date 1/1/1970).addhours(-7)).addseconds($_.'last-operation-end-timestamp') - ((get-date -date 1/1/1970).addhours(-7)).addseconds($_.'last-operation-begin-timestamp') )}
$Output|  %{$_.StartTime = (((get-date -date 1/1/1970).addhours(-7)).addseconds($_.'last-operation-begin-timestamp'))}
$Output
}
function global:Get-SIS-LongJobs ($NaServer){
$output = Get-SIS-Status ($NaServer)
$output |Sort-Object State, duration -descending| Select-Object path, duration, schedule, 'last-operation-size', State| ft -AutoSize
}
function global:Set-SIS-config ($NaServer, $volume, $schedule){
$naelement = New-Object netapp.manage.naelement("sis-set-config")
$NaElement.AddNewChild('path',$volume)
$NaElement.AddNewChild('schedule',$schedule)
([xml]($NaServer.invokeelem($naelement)).tostring()).results.'sis-object'
}
function global:start-SIS ($NaServer, $volume){
$naelement = New-Object netapp.manage.naelement("sis-start")
$NaElement.AddNewChild('path',$volume)
$null = ([xml]($NaServer.invokeelem($naelement)).tostring()).results.'sis-object'
}
function global:stop-SIS ($NaServer, $volume){
$naelement = New-Object netapp.manage.naelement("sis-stop")
$NaElement.AddNewChild('path',$volume)
$null = ([xml]($NaServer.invokeelem($naelement)).tostring()).results.'sis-object'
}
function  global:Set-SIS-ON($NaServer, $volume, [switch]$SISOFF )
{
if (-not $SISOFF){
	$naelement = New-Object netapp.manage.naelement("sis-enable")
	$NaElement.AddNewChild('path',$volume)
	$null = ([xml]($NaServer.invokeelem($naelement)).tostring()).results.'sis-object'
	}
else{
	$naelement = New-Object netapp.manage.naelement("sis-disable")
	$NaElement.AddNewChild('path',$volume)
	$null = ([xml]($NaServer.invokeelem($naelement)).tostring()).results.'sis-object'
	}
}
function global:Start-SIS-All ($NaServer, $MaxJobs = 4){
$StartTime = get-date
foreach ($path in (Get-SIS-status $NaServer|%{$_.path})){
	while (@(Get-SIS-status $NaServer|?{$_.status -eq "Active"}).count -ge $MaxJobs){start-sleep 15; write-host "." -nonewline}
	write-host "Starting $Path"
	start-sis $NaServer $Path
	Start-Sleep 5}
Write-Host "This task took: $((get-date) - $StartTime)"
}

#-----------------------Snapshot functions
function global:get-Snap-AutoDeleteInfo ($NaServer)
{
	$naelement = New-Object netapp.manage.naelement("volume-list-info")
	$volumes = ([xml]($NaServer.invokeelem($naelement)).tostring()).results.volumes.'volume-info'
	foreach ($vol in $volumes){
		$naelement = New-Object netapp.manage.naelement("snapshot-autodelete-list-info")
		$NaElement.AddNewChild('volume',$Vol.name)
		$snapInfo = ([xml]($NaServer.invokeelem($naelement)).tostring()).results.options.'snapshot-autodelete-info'
		$myobj = "" | Select-Object Volume, state, commitment, trigger, target_free_space, delete_order, defer_delete, destroy_list
		$myobj.Volume = $vol.name
		foreach ($option in $snapInfo){$myobj.($option.'option-name') = $option.'option-value'}
		$myobj
	}
}
function global:set-Snap-AutoDeleteInfo ($NaServer, $volume, $state="on", $commitment="try", $trigger="volume", $targer_free_space="15", $delete_order="oldest_first", $defer_delete="user_created"){
	$Options = @($state, $commitment, $trigger, $targer_free_space, $delete_order, $defer_delete)
	$OptionNames = @("state", "commitment", "trigger", "target_free_space", "delete_order", "defer_delete")
	foreach ($Counter in (0..5)){
		$naelement = New-Object netapp.manage.naelement("snapshot-autodelete-set-option")
		$NaElement.AddNewChild('volume',$volume)
		$NaElement.AddNewChild('option-name', $OptionNames[$counter])
		$NaElement.AddNewChild('option-value',$Options[$counter])
		$null = $NaServer.invokeelem($naelement)
		}	
}
function global:get-Snap-List ($NaServer)
{
	$naelement = New-Object netapp.manage.naelement("volume-list-info")
	$volumes = ([xml]($NaServer.invokeelem($naelement)).tostring()).results.volumes.'volume-info'
	foreach ($vol in $volumes){
		$naelement = New-Object netapp.manage.naelement("snapshot-list-info")
		$NaElement.AddNewChild('target-type','volume’)
		$NaElement.AddNewChild('target-name',$Vol.name)
		$snapshots = ([xml]($NaServer.invokeelem($naelement)).tostring()).results.snapshots.'snapshot-info'
		foreach ($Snap in $snapshots){
			$myobj = "" | Select-Object Volume, Name, accesstime, totalMB, CTotalMB, POfUsedB, CPOfUsedB
			$myobj.Volume = $vol.name
			$myobj.name = $Snap.name
			$myobj.accesstime = ((get-date -date 1/1/1970).addhours(-7)).addseconds($Snap.'access-time')
			$myobj.totalMB = [Math]::round($Snap.total / 1kb, 2)
			$myobj.CTotalMB = [Math]::round($Snap.'cumulative-total' /1kb, 2)
			$myobj.POfUsedB = $Snap.'percentage-of-used-blocks'
			$myobj.CPOfUsedB = $Snap.'cumulative-percentage-of-used-blocks'
			$myobj
		}
	}
}
function global:get-SnapList-Top-Total(){
	$Snaps = (get-Snap-List $1504) + (get-Snap-List $1505)
	"Top 20 Large Snapshots"
	$Snaps|sort-object -prop totalMB -desc| select-object -first 20 | ft -AutoSize
	"Top 20 Snapshot footprint"
	$Snaps| Group-Object -Property volume|%{$_.group|sort-object -prop accesstime|select-object -First 1 }| sort-object -prop CtotalMB -desc| select-object -first 20|ft -AutoSize
	"Top 5 Oldest Snapshots"
	$Snaps| Group-Object -Property volume|%{$_.group|sort-object -prop accesstime|select-object -First 1 }| ?{$_.name -ne $null}|sort-object -prop accesstime| select-object -first 5 | ft -AutoSize
}
function global:rename-Snap($NaServer, $CurrentName, $newName, $volume){
	$naelement = New-Object netapp.manage.naelement("snapshot-rename")
	$NaElement.AddNewChild('current-name',$CurrentName)
	$NaElement.AddNewChild('new-name',$newName)
	$NaElement.AddNewChild('volume',$volume)
	$null = $NaServer.invokeelem($naelement)
}
function global:remove-Snap($NaServer, $Snapshot, $volume){
	$naelement = New-Object netapp.manage.naelement("snapshot-delete")
	$NaElement.AddNewChild('snapshot',$Snapshot)
	$NaElement.AddNewChild('volume',$volume)
	$null = $NaServer.invokeelem($naelement)
}
function global:get-snap ($NaServer, $volume){
	$naelement = New-Object netapp.manage.naelement("snapshot-list-info")
	$NaElement.AddNewChild('target-type','volume’)
	$NaElement.AddNewChild('target-name',$volume)
	$snapshots = ([xml]($NaServer.invokeelem($naelement)).tostring()).results.snapshots.'snapshot-info'
	foreach ($Snap in $snapshots){
			$myobj = "" | Select-Object Volume, Name, accesstime, totalMB, CTotalMB, POfUsedB, CPOfUsedB
			$myobj.Volume = $volume
			$myobj.name = $Snap.name
			$myobj.accesstime = ((get-date -date 1/1/1970).addhours(-7)).addseconds($Snap.'access-time')
			$myobj.totalMB = [Math]::round($Snap.total / 1kb, 2)
			$myobj.CTotalMB = [Math]::round($Snap.'cumulative-total' /1kb, 2)
			$myobj.POfUsedB = $Snap.'percentage-of-used-blocks'
			$myobj.CPOfUsedB = $Snap.'cumulative-percentage-of-used-blocks'
			$myobj
		}
}
function global:New-Snap ($NaServer, $SnapPrefix, $volume, $MaxSave = 5){
	if ([int]$MaxSave -lt 1) {return -1}
	$CurrentSnaps = get-snap $NaServer $volume
	$CurrentSnaps = @($CurrentSnaps| ?{$_.name -match "^$SnapPrefix\.\d+$"}| Sort-Object -Property accesstime )
	#"count: $($CurrentSnaps.count) - $MaxSave = $($CurrentSnaps.count  - $MaxSave)"
	if ($CurrentSnaps.count -gt $MaxSave-1 -and $CurrentSnaps.count -gt 0) {#remove Oldest Snap
		#"hit cleanup process"
		foreach ($i in 0..($CurrentSnaps.count  - $MaxSave )){
			#"Removing: $($CurrentSnaps[0].Name)"
			remove-snap $NaServer $CurrentSnaps[0].Name $volume
			$CurrentSnaps = @($CurrentSnaps| ?{$_.name -ne $CurrentSnaps[0].Name})
			}	
	}
	#"current snaps after removals"
	#$CurrentSnaps|%{$_.name}
	if ($CurrentSnaps -ne $null){
		foreach ($Snap in $CurrentSnaps){
				$null = $Snap.name -match "^$SnapPrefix\.(?<digit>\d+)$"
				rename-snap $NaServer $Snap.name "$SnapPrefix.$([int]$matches.digit+1)" $volume
				#"Renaming: $($Snap.name) -> $SnapPrefix.$([int]$matches.digit+1)"
			}
		}
	$naelement = New-Object netapp.manage.naelement("snapshot-create")
	$NaElement.AddNewChild('snapshot',"$SnapPrefix.0")
	$NaElement.AddNewChild('volume',$volume)
	$null = $NaServer.invokeelem($naelement)
}
# --------------- Lun functions
function Set-LUN-Caption ($NaServer, $LUNpath, $Comment){
	$naelement = New-Object netapp.manage.naelement("lun-set-comment")
	$NaElement.AddNewChild('comment',$comment)
	$NaElement.AddNewChild('path',$LUNpath)
	$null = ($NaServer.invokeelem($naelement)).tostring()
}
function global:get-Lun-Info ($NaServer, $LUNpattern='.*'){
	$naelement = New-Object netapp.manage.naelement("lun-list-info")
	$LUNs = ([xml]($NaServer.invokeelem($naelement)).tostring()).results.luns.'lun-info'
	$LUNs| ?{$_.path -match $LUNpattern}| Sort-Object path
}
function global:Map-Lun ($NaServer, $LUNpath, $iGroup, $LUNid){
	$naelement = New-Object netapp.manage.naelement("lun-map")
	$NaElement.AddNewChild('path',$LUNpath)
	$NaElement.AddNewChild('initiator-group',$iGroup)
	$NaElement.AddNewChild('lun-id',$LUNid)
	$null = ($NaServer.invokeelem($naelement)).tostring()
}
function global:Get-LUN-Map ($NaServer, $filter ='.*'){
	$LUNs = get-Lun-Info $NaServer
	$Maps = foreach ($LUN in $LUNs){
		$naelement = New-Object netapp.manage.naelement("lun-map-list-info")
		$NaElement.AddNewChild('path',$LUN.path)
		$Groups = ([xml]($NaServer.invokeelem($naelement)).tostring()).results.'initiator-groups'.'initiator-group-info'
		$groups | Add-Member -MemberType noteproperty -Name path -Value $LUN.path -Force -PassThru
	} 
	$Maps| ?{$_.'initiator-group-name' -match $filter -or $_.path -match $filter}|Sort-Object path, 'lun-id'
}
function global:copy-LUN-Map ($NaServer, $SourceiGroup, $DestinationiGroup, $filter = '.*'){
	$LUNmaps = Get-LUN-Map $NaServer $SourceiGroup $filter
	foreach ($LUNmap in $LUNmaps){
		Map-Lun $NaServer $LUNmap.path $DestinationiGroup $LUNmap.'lun-id'
	}
}
#------------- Performance functions
function list {$args}
function global:Print-NaMatrix($values){
	$c =list b c c c c d d d g g c d d d d g g g y y c d d d d g g g y y c d d d d g g g y y c d d d d g g g y y d g g g g y y y m m d g g g g y y y m m d g g g g y y y m m g y y y y m m m r r g y y y y m m m r r
	$d = $c|%{ switch ($_) { "b" {"cyan"}; "c" {"cyan"}; "d" {"darkgreen"}; "g" {"Green"}; "y" {"Yellow"}; "m" {"magenta"}; "r" {"Red"}}}
	$x=0;$values|%{$x=$x+$_}
	1..100|%{if ($_ % 10 -eq 0){write-host ("{0:P2}" -f (($values[$_-1])/$x)) -for $d[$_-1]} else {write-host ("{0:P2}" -f (($values[$_-1])/$x)) -for $d[$_-1] -no}}
}
function global:Get-NaCounter($Filer, $counter){
	$naelement = New-Object netapp.manage.naelement("perf-object-get-instances")
	$NaElement.AddNewChild(’objectname’,'perf’)
	$results = [xml]($Filer.invokeelem($naelement)).tostring()
	$myobj = "" | Select-Object Value, Timestamp
	$myobj.TimeStamp = ((get-date -date 1/1/1970).addhours(-7)).addseconds($results.results.timestamp)
	$value = ($results.results.instances.'instance-data'.counters.'counter-data'|?{$_.name -eq $counter}).value
	$myobj.Value = if ($value){$value} else{"Missing Counter"}
	$myObj
}
function global:Get-NaCounter-TimeSlice($NaServer, $counter = 'disk_user_reads_latency_histogram', $timeSample = 10){
	$values1 = (Get-NaCounter $NaServer $counter).Value
	$values1= [regex]::split($values1,",")
	Start-Sleep $timeSample
	$values2 = (Get-NaCounter $NaServer $counter).Value
	$values2= [regex]::split($values2,",")
	$values =(0..($values1.count))|%{($values2[$_] - $values1[$_])}
	$values
}
function global:Get-NaMatrix-Full($NaServer){
	$values = (Get-NaCounter $NaServer 'cpu_disk_util_matrix').Value
	$values= [regex]::split($values,",")
	Print-NaMatrix $values
}
function global:Get-NaMatrix-TimeSlice($NaServer,$timeSample = 10){	
	Print-NaMatrix (Get-NaCounter-TimeSlice $NaServer 'cpu_disk_util_matrix' $timeSample)
}

#------------- Get and Set netapp options functions

function global:Set-NaOption ($NaServer, $OptionName, $OptionValue){
	$naelement = New-Object netapp.manage.naelement("options-set")
	$NaElement.AddNewChild('name',$OptionName)
	$NaElement.AddNewChild('value',$OptionValue)
	$null = [xml]($NaServer.invokeelem($naelement)).tostring()
	Get-NaOption $NaServer "^$OptionName"
}
function global:Get-NaOption ($NaServer, $Search = '.*'){
	$naelement = New-Object netapp.manage.naelement("options-list-info")
	$Options = ([xml]($NaServer.invokeelem($naelement)).tostring()).results.options.'option-info'
	$Options|?{$_.name -match $Search}
}

