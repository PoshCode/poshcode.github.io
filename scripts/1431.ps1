################################################################################
# Copy-Backup.ps1
# This script will backup recently changed .ps1 files from any selected folder
# (default is $pwd) to any number of inserted USB devices, on which an archive  
# folder PSarchive will be created if it does not already exist.
# The author may be contacted via www.SeaStarDevelopment.Bravehost.com
################################################################################
Param ([Switch]$debug,
       [String]$folder = $pwd)
If ($debug) {
    $DebugPreference = 'Continue'
}
$drive = 'blank'
If (!(Test-path $folder -pathType Container )) {
	[System.Media.SystemSounds]::Hand.Play()
	Write-Warning "$folder is not a directory - resubmit."
	Break
}
Get-WMIObject Win32_LogicalDisk -filter "DriveType = 2" |`
    Select-Object Name, VolumeName, DriveType, FreeSpace |`
    Where-Object {$_.VolumeName -ne $null} |`
ForEach {
    $drive = $_.Name            #Store these values otherwise overwritten below.
    $vol   = $_.VolumeName
	$type  = $_.DriveType
	[int]$free  = $_.FreeSpace / 1MB
	Write-Debug "Scanning USB devices - $drive Name = $vol, Free = $free Mb"
    If ((Test-Path $drive) -eq $False ) {
        Write-Warning "Error on drive $drive - restart."
		[System.Media.SystemSounds]::Hand.Play()
        Break   
    }
    [int]$files = 0                           #Reset counter for each new drive.
    $newFolder = $drive + "\PSarchive"                  #Check if folder exists.
    If ((Test-Path $newFolder) -eq $False) {
        New-Item -path ($drive + "\") -name PSarchive -type directory | Out-Null
    }
    (Get-ChildItem $folder -filter *.ps1) | 
    ForEach {
        $replacing = Get-ChildItem ($drive + "\PSarchive\" + $_.Name) `
            -ErrorAction SilentlyContinue
        If (!$replacing) {              #An error here means the file not found.
            $lwt = "None"                 #Anything to force backup match below.
        }                             #File exists, so check before overwriting.
        Else {
            $lwt = $replacing.LastWriteTime
        }    
        If ($lwt -ne $_.LastWriteTime) {                 #Compare the two times.
            $output = "{0}\PSarchive" -f $drive
            Copy-Item $_.FullName -destination $output -force 
            Write-Host "--> Archiving file:" $_.Name
            $files++
        } 
    }
    $print =  " Backup to USB drive <{0}> (Volume = {2}) completed; {1} files copied." -f $drive, $files, $vol
    Write-Host "-->$print"
}
If ($drive -eq 'blank') {
    [System.Media.SystemSounds]::Asterisk.Play()
	Write-Warning "No USB drive detected - Insert a device and resubmit."  
}

