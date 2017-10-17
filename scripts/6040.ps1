#This script extracts the UNC paths from all login scripts associated to users.
#Author: Justin Grote

#Netlogon Path

param (
[String]$netlogonpath = "\\" + $env:USERDNSDomain + "\netlogon\",
[Switch]$IncludeAllNetlogonBatVBS = $true,
$NetLogonFilesToSearch = ("*.bat","*.vbs")
)

############# SCRIPT #################

#Get Legacy Logon Script Paths
$logonscripts = get-aduser -filter * -properties scriptpath | select samaccountname,scriptpath

#Get a list of unique login scripts
$scriptpaths = $logonscripts.scriptpath | foreach {if ($PSItem) {$PSItem.tolower()}}

#Add all the script paths from NetLogon if specified
if ($NetLogonFilesToSearch) {
    $scriptpaths += (get-childitem $netlogonpath -include $NetLogonFilesToSearch -recurse).fullname | foreach {if ($PSItem) {$PSItem.tolower()}}
}

#Remove Duplicates
$scriptpaths = $scriptpaths.trim() | select -unique | sort

#Get the UNC paths in each file
foreach ($scriptpath in $scriptpaths) {
    write-progress "Scanning $scriptpath"
    #If script doesn't have UNC path, append the netlogon path, otherwise use as-is
    if ($scriptpath -notmatch '\\') {$scriptpath = $netlogonpath + $scriptpath}

    #Retrieve all UNC paths in the document
    select-string -Path $scriptpath -allmatches -pattern '\\\\.*\\.*' -erroraction stop | select filename,linenumber,line
}
