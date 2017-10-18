$dest = "c$\data"

$src = "\\src\dir\*"

$computers = gc "\\src\dir\computers.txt"

foreach ($computer in $computers) {
    if (test-Connection -Cn $computer -quiet) {
        "$computer is online, mapping drive."

        New-PSDrive -name T -psprovider FileSystem -root \\$computer\c$

        "$computer drive mapped, starting DB copy"

        Copy-Item $src -Destination T:\data -Recurse

        "Transfer to $computer complete. Running cleanup."

        Remove-PSDrive T

        "Done."
        

    } else {
        "$computer is not online"
    }

}
