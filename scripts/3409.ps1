# 
# simple example using a hash to parse CAS Connect Logs
#
# after using the get-CASConnectLogEntries.ps1 to collect the log information
# this script runs thru those files and counts Cached vs Classic
#
#


# the directory where you keep these "cas connect logs" - change to fit your needs
$Script:CasLogUNCDir   ='\\<server>\<drv>\Web\Data\CASConnectLogs'

# Hast Table to hold results : LegacyExchangeDN-Clientversion, Mode
$Cleints = @{}

foreach ($Line in (gci $Script:CasLogUNCDir | gc) ) {
    #legacyExchangeDN
    $LEDN = $Line.Split(",")[3]
    
    #Outlook version
    $OLVER = $Line.Split(",")[6]
    
    #ClientMode
    $Mode = $Line.Split(",")[7]

    if(-not ($Clients.ContainsKey($LEDN+'-'+$OLVer))) {
        $Clients.Add($($LEDN+'-'+$OLVer),$MODE)
    }
}

"Total Clients [ {0} ]; Cached [ {1} ]; Classic [ {2} ]"-f ($Clients.Count),(($Clients.getenumerator() | ?{$_.value-match'Cached'}).Count),(($Clients.getenumerator() | ?{$_.value-notmatch'Cached'}).Count)


