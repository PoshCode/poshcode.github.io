param(
$RootFolder = "\\domain.local\users",
$NewRootFolder = "\\domain.local\users2",
$LogFolder = "c:\Projects\HomeDirs",
$NewSubFolders = @("Documents","Favorites","Desktop","Links","Contacts","BlaBla"),
[switch]$SetACL
)
$UserFolders = gci -Path $RootFolder | ?{$_.PSIsContainer}
$UserFolders | foreach-object -Process {
	#create new homedrive
	$NewUserFolder =  $NewRootFolder + "\" + $_.name
	if ($SetACL){
		#set ACL rules for new homedrive
		$acl = Get-Acl $_.FullName
		$Owner = New-Object System.Security.Principal.NTAccount("uza.local",$_.name)
		$acl.SetOwner($Owner)
		$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($_.Name,"Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
		$acl.AddAccessRule($rule)
		}
	#create required subfolders per homedrive
	$NewSubFolders | foreach{New-Item -Path $($NewUserFolder + "\" + $_) -type directory}
	#build robocopy job per homedrive
	$LogFile = $LogFolder + "\" + $_.name + ".log"
	$JobName = $_.name + "_RCsync"
	$CommandString = "robocopy $($_.FullName) $($NewUserFolder + "\Documents") /COPYALL /MIR /FFT /Z /Log+:$LogFile"
	start-job -Scriptblock {invoke-Expression $input} -name $JobName -InputObject $CommandString
    }
#Wait for all jobs
Get-Job | Wait-Job
#Get all job results
Get-Job | Receive-Job 
