
$name = Read-Host 'SSIS_DUMMY?'
$E = $name

$Location = "D:\MVCApplication\"
New-Item -Path $Location -name  $E -ItemType "directory"
