# Tip of the hat to @daniel_rehn for original idea
# based on the image he tweeted of seeyouspacecowboy.sh 
# his shell script is here :: https://gist.github.com/danielrehn/d2e6f2129e5f853c3166
# This is my take in PowerShell (I think I got the ascii art right)
# Author := @randal_hicks

function cya($spacecowboy)
{
$foo = @"
 .d8888b.  8888888888 8888888888      Y88b   d88P  .d88888b.  888     888
d88P  Y88b 888        888              Y88b d88P  d88P" "Y88b 888     888
 "Y888b.   8888888    8888888            Y888P    888     888 888     888
    "Y88b. 888        888                 888     888     888 888     888
      "888 888        888                 888     888     888 888     888
Y88b  d88P 888        888                 888     Y88b.  d88P Y88b. .d88P
 "Y8888P"  8888888888 8888888888          888      "Y88888P"   "Y88888P"
 .d8888b.  8888888b.     d8888  .d8888b.  8888888888
d88p  Y88b 888   Y88b   d88888 d88P  Y88b 888
 "Y888b.   888   d88P d88P 888 888        8888888
    "Y88b. 8888888P" d88P  888 888        888
      "888 888      d88P   888 888    888 888
Y88b  d88P 888     d8888888888 Y88b  d88P 888
 "Y8888P"  888    d88P     888  "Y8888P"  8888888888
 .d8888b.   .d88888b.  888       888 888888b.    .d88888b. Y88b   d88P
d88P  Y88b d88P" "Y88b 888   o   888 888  "88b  d88P" "Y88b Y88b d88P
888        888     888 888 d888b 888 8888888K.  888     888   Y888P
888        888     888 8888888888888 888  "Y88b 888     888    888
888    888 888     888 88888P Y88888 888    888 888     888    888
Y88b  d88P Y88b. .d88P 8888P   Y8888 888   d88P Y88b. .d88P    888
 "Y8888P"   "Y88888P"  888P     Y888 8888888P"   "Y88888P"     888
"@
 $file="c:\.seeyouspacecowboy"
 $foo | out-file $file
 $colour=("red","yellow","darkyellow","green","cyan","darkcyan","darkmagenta")
 [int]$num=-1
 $info = (get-content $file)
 Write-Host ""
 foreach($i in $info) 
    {
     [int]$perspective=($num / 3)
     write-host $i -foregroundcolor $colour[$perspective]
     $num++   
    }
 Write-Host ""
}
cya($spacecowboy)
