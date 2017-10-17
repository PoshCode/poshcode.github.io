#Created By: Ty Lopes
#Sept 2012
#Sript to be run by a scheduled task that monitors for a specific event ID (in this case account locked)
#The sript then reads the last correstponding event ID and emails the details
#I could only get this alert to work properly by using this method... There may be something easier/better for you out there.
#This process will have to be followed for each domain controller (since any DC may lock the account and others may not trigger the event id
#We have two DC's so this worked well for us
#The account the task runs under obviously needs rights to read the event logs on the DC

#Setup the Task
#Create a scheduled task
#On the general tab, Run Wether user is logged on or not and Run with highest priveledges
#On the triggers tab, Select NEW, "On an Event".
#Populate 
	#log: Security
	#Source: Microsoft-Windows-security-auditing
	#Event ID: 4740

#Under Actions: New: STart a program:
#Program: powershell.exe
#Arguments: -command "& 'C:\scripts\accountLocked.ps1' "  (pointing to wherever your script lives)


#Script Start

	start-sleep 10

	$dcName = "DomainController"
	$eventID = "4740"
	$mailServer = "smtpServer"
	$eSubject = "AD account locked"
	$emailAddy = "user@domain.com"

	$lockEvent = get-eventlog -logname security -computername $dcName -instanceid $eventID -newest 1

	$emailBody = $lockEvent.message
	Send-MailMessage –From lockedAccount@domain.com –To $emailAddy –Subject $eSubject –Body $emailBody –SmtpServer $mailServer

#Script end

