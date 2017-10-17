## Selected 'Exif' statistics script is below. There are a number of ways I can improve it: 
## Stream output, skip csv file creation (as an interim step) read list with arrays and parameters,
## using regex expressions to best effect. Still, quite a few lessons learned with this and the output can help 
## check for errors. The issue is that 'exif' (Cygwin, GNU utility) will sometimes skip fields. I am not checking ## for that or other  error conditions in general, but the 'Counts' need to sync up at least. 


$exif_index  =  gci *.jpg | %{exif ($_.Name)}
$c = $exif_index | Select-String -pattern "EXIF tag" , FNumber , "Focal Length In 35mm"
$c1 =  ("$c").Split(  ) | Select-String -pattern JPG , f/ , mm
$c2 = (("$c1").Replace( "'" , "")).Split()
$c3 = (("$c2").Replace( " |f/" , ",")).Split()
$c4 = (("$c3").Replace( " 35mm|" , ",")).Split()

if ((gci PhotoData.csv).Exists -eq "True") {mv PhotoData.csv PhotoData.csv.old -force}
else {}

"Exif_Tag,FNumber,Focal_Length" | out-file PhotoData.csv
$c4 | out-file -append PhotoData.csv
$PhotoData = import-csv -path PhotoData.csv

$FileName =  ( $PhotoData | Measure-Object -Property Exif_Tag  )
$FNumber = ( $PhotoData | Measure-Object -Property FNumber  -average -maximum -minimum ) 
$Focal_Length = ( $PhotoData | Measure-Object -Property Focal_Length  -average -maximum -minimum ) 

echo $FileName
echo $FNumber
echo $Focal_Length

