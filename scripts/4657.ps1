﻿$filesize = (get-item F:\pastuhov\keywords\aa2.txt).length
$fileread = New-Object System.IO.BinaryReader([System.IO.File]::Open("F:\pastuhov\keywords\aa2.txt", [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite))
$filewrite= New-Object System.IO.BinaryWriter([System.IO.File]::Open("F:\pastuhov\keywords\aaaaaaaaaaa.txt", [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite))

$i=0
do {
	$a = $fileread.ReadBytes(10000);
	$i += 10000
    Get-Date
    Write-Host $a.Length
	if (($a -contains 0x00) -eq 1){
        write-host 'chistka'
		$a = $a | ? { $_ -ne 0x00}
	}
    if ($a.Length -ne 0){
	    $filewrite.Write($a);
    }
} while ($i -lt $count)



$fileread.Close()
$filewrite.Close()
