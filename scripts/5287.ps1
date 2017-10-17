# clamscan version 0.1
# Note that this assumes a standardized installation of the software
# You will also need a valid conf file such as the following:
@"

    # URL of server where database updates are to be downloaded from
    # If this option is given multiple times, each will be tried in
    # the order given until an update is successfully downloaded
    DatabaseMirror database.clamav.net
    # Number of times to try each mirror before moving to the next one
    MaxAttempts 3

"@
# To use, pass it a valid path and it will return text of anything it finds

function clamscan ($path) 
{
$results = "c:\clamscan.txt"
& "c:\program files (x86)\clamwin\bin\freshclam.exe" --datadir="C:\ProgramData\.clamwin\db" --config-file="C:\Program Files (X86)\ClamWin\bin\freshclam.conf"
& "c:\program files (x86)\clamwin\bin\clamscan.exe" --database="C:\ProgramData\.clamwin\db" --recursive $path | out-file $results
"Results of Clamscan for $path :"
get-childitem $results  | select-string -pattern "FOUND" -casesensitive 
}

