#############################################################################################
#
# NAME: RDP.ps1
# AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com @fade2blackuk
# DATE:15/05/2013
#
# COMMENTS: This script to open a RDP
# ------------------------------------------------------------------------

$server = Read-Host "Server Name?"
Invoke-Expression "mstsc /v:$server"
