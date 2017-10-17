$date = Get-Date -Format "yyyyMMdd"
$source = 'C:\dir'
$destination = "C:\someotherdir\$date\"

New-Item -ItemType directory -Path $destination
Copy-Item $source "$destination" -Recurse -Force
