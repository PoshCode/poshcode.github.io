###############################################################################################################################
# Script: getmacs.ps1
# Description: Very basic script that gets mac addresses (NetBIOS table) from a list of remote hosts. Overkill notes I know.  :)
# Qodosh
# Date: 2.14.2014 
# Version: 1.1
# Usage: 
# 1. Make a text file with a list of hosts names that you want to get mac addresses from. 
# 2. Edit $strservers in-between the quotes and enter the path to your list. Make sure to put the extension .txt
# 3. Edit $log in-between the quotes. Put the location you want to make the log file. Also do a .txt extension.
#
# Location of the servers you want to grab a NetBIOS table from
$strservers = 'C:\servers.txt'
# Puts the content of the server lists into a variable
$Servers = Get-Content $strservers
# Location of the log file. Feel free to change.
# I assigned the log to a variable as this will have new uses in future versions.
$log = 'c:\log.txt'
# Loops through each server performing a simple nbtstat command and pipes output to log variable.
# If you have issues with the command just change the nbtstat switch below. Type nbtstat in command line to see your options
foreach ($Server in $Servers)
{
    nbtstat -a $Server >> $log
} 
# Opens log file once operation completes
start $log

