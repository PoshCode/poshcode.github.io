function burn()
{
#get the files and ship them to burn-file
dir -recurse -include *.iso -path c:\,d:\,e:\ | foreach { burn-file $_.FullName }
}

function burn-file($filename)
{
#call img burn with the nessessary arguments
. "c:\Program Files\ImgBurn\ImgBurn.exe" /mode ISOWRITE /WAITFORMEDIA /start /close /DELETEIMAGE /EJECT /SRC $filename
#Wait for IMGBURN to finish (right now you can only have one open at a time)
while ( (get-process | where{$_.ProcessName -eq "ImgBurn"}) -ne $null)
{
#sleep for a bit to let the processor work on burning
Start-Sleep â€“s 10
#tell the user what file you are still working on
"waiting for $filename to complete"
}

}

#call the burn function
burn

