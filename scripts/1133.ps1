$File = "D:\Dev\somefilename.zip"
$ftp = "ftp://username:password@example.com/pub/incoming/somefilename.zip"

"ftp url: $ftp"

$webclient = New-Object System.Net.WebClient
$uri = New-Object System.Uri($ftp)

"Uploading $File..."

$webclient.UploadFile($Uri, $File)

