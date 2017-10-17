#############################################################################################
#
# NAME: Ping.ps1
# AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com @fade2blackuk
# DATE:15/05/2013
#
# COMMENTS: This script to set up a continous ping 
# Use CTRL + C to stop it
# ------------------------------------------------------------------------

$server = Read-Host "Server Name?"
Invoke-Expression "ping -t $server"
