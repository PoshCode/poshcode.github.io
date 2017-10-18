**********EDIT: See Carter's Example, it's way simpler: http://poshcode.org/1559**********

###ESXi Configuration Backup Script
#DESCRIPION: This Script takes a CSV file with the hostname, username, and password of a list of ESXi servers, and backs up their configurations to a specified Destination
#USAGE: This script is meant to be run as a regular scheduled task or a pre-script for a backup job. There is no version control, so it is recommended to use an external backup program (Such as Backup Exec) to scan this.
#LAST MODIFIED: 15 Dec 2009 by JGrote <jgrote AT enpointe NOSPAMDOT-com>
#REQUIREMENTS: 
#VMWare Remote CLI (Tested with 4.0U1)


### SETTINGS

#Location of the VMWare Remote CLI vicfg-cfgbackup.pl command (will be different for 32-bit systems)
$vSphereCLIPath = "C:\Program Files (x86)\VMware\VMware vSphere CLI\"
#Backup Destination Folder
$BackupDest = "E:\Backup\ESXi"
#Path to ESXi CSV File. APPLY STRICT PERMISSIONS TO THIS FILE SO THAT ONLY THE SCRIPTAND ADMINISTRATORS CAN READ IT! 
#Format: 
#1st Field - HOSTNAME - ESXi IP Address or Hostname
#2nd Field - USERNAME - Local Username (usually root)
#3rd Field - PASSWORD - Password
#
#Example:
#HOSTNAME,USERNAME,PASSWORD
#server1,root,password
#server2,root,password2
#It is recommended to create and edit this file using Excel (Save as CSV)
$ESXiCSV = "C:\Scripts\ESXiBackupList.csv"

### PREPARATION
#Create an ESXi Backup Event Source if it doesn't already exist
$eventsource = "Backup-ESXi"
$eventlog = "Application"
if (!(get-eventlog -logname $eventlog -source $eventsource)) {new-eventlog -logname $eventlog -source $eventsource}
#Write an error and exit the script if an exception is ever thrown
trap {write-eventlog -logname $eventlog -eventID 1 -source $eventsource -EntryType "Error" -Message "An Error occured during $($eventsource): $_ . Script run from $($MyInvocation.MyCommand.Definition)"; exit}

#Verify the Destination Directory Exists:
#Verify that the import XML file was created. If it is not there, it will throw an exception caught by the trap above that will exit the script.
$ESXiCSVIsPresentTest = Get-Item $ESXiCSV



### SCRIPT
#Read Each Host from the File and back up the config to the backup directory
import-csv $ESXiCSV | ForEach-Object {
    $BackupResult = invoke-expression "& '$vSphereCLIPath\perl\bin\perl.exe' '$vSphereCLIPath\bin\vicfg-cfgbackup.pl' --server $($_.HOSTNAME) --username $($_.USERNAME) --password $($_.PASSWORD) --save $($BackupDest)\$($_.HOSTNAME)-cfgbackup.tgz"
    if ($LastExitCode -ne 0) {throw "An Error occurred while executing $BackupBin for $($_.HOSTNAME): $BackupResult"}
}

#Compose and Write Success Event
$successText = "ESXi Configurations were successfully backed up to $BackupDest. Script run from $($MyInvocation.MyCommand.Definition)""
write-eventlog -logname $eventlog -eventID 1 -source $eventsource -EntryType "Information" -Message $successText
