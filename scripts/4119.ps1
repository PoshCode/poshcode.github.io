﻿#Write-Twilight
while(1){
    $wc = Get-Random -Minimum (Get-Random -Minimum 1 -Maximum 3) -Maximum (Get-Random -Minimum 4 -Maximum 14)
    for($y=0; $y-lt$wc; $y++){
        $word = ""
        $max = Get-Random -Minimum 5 -Maximum 11
        $wl = Get-Random -Minimum 1 -Maximum $max
                
        for($i=0;$i-lt$wl;$i++){
	        $num = Get-Random -Minimum 97 -Maximum 122;
	        $char= [char][int]$num;
	        $word += [string]$char
	        Start-Sleep -Milliseconds (Get-Random -Maximum 150 -Minimum 3)
        }
        #.\readwords.ps1 $word #From previous script
        Write-Host -NoNewline "$word "
        #Start-Sleep -MilliSeconds (Get-Random -Maximum 1000 -Minimum 500)
        
    }
    switch (Get-Random -Minimum 1 -Maximum 11){
        1 {Write-Host -NoNewline ","}
        2 {Write-Host -NoNewline ".`nGril: "}
        3 {Write-Host -NoNewline "!`nBella: "}
        4 {Write-Host -NoNewline "?`nShovel Face: "}

        5 {Write-Host -NoNewline ";"}
        6 {Write-Host -NoNewline ":"}
        7 {Write-Host -NoNewline "`""}
        8 {Write-Host -NoNewline "'"}

        11 {Write-Host -NoNewline ".`nMouth Breath: "}
        10 {Write-Host -NoNewline "!`nFish Face: "}
        9 {Write-Host -NoNewline "?`nThing: "}
    }
    Start-Sleep -Seconds 1
}
