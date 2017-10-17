#==========================================================================
# NAME: Get-DNSZoneRecords.ps1
# AUTHOR: Saehrig, Steven (trac3r726)
# DATE  : 10/17/2008
#
# COMMENT: 
# Just comment out the variable and enter the info you need for 
# computername, dnszonename, and remove the credential portion if not needed.
# Otherwise on Execution you will be prompted for credentials and IP.
#==========================================================================
param(
  $computer = $(Read-Host "Server IP:"),
  $cred = $(Get-Credential)
)

$dnszonename = (Get-WmiObject Win32_computersystem -computerName $computer -credential $cred).domain

get-wmiobject -namespace "root\microsoftdns" -class microsoftdns_atype -computername $computer `
              -credential $cred -filter "containername='$dnszonename'" | 
ft  dnsservername, ownername, recorddata, ttl
