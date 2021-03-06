<#
.SYNOPSIS
Writes out the the words for 99 Bottle of Beer on the wall.

.DESCRIPTION
Writes out the the words for 99 Bottle of Beer on the wall.

.PARAMETER BottlesOfBeerOnTheWall
Give the starting number of how many bottles of beer that are on the wall. 
Valid range is 2 to 99.

.PARAMETER Voice
Use if you want a voice to the song.

.EXAMPLE
Sing-FolkSong -BottlesOfBeerOnTheWall 99

Ninety-nine bottles of beer on the wall, ninety-nine bottles of beer.
Take one down pass it around, ninety-eight bottles of beer on the wall.

...

One bottle of beer on the wall, one bottle of beer.
Take one down pass it around, zero bottles of beer on the wall.
#>

[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [ValidateRange(0,99)] 
    [Alias('BottlesOfBeer')]
    [int]$BottlesOfBeerOnTheWall=99,

    [switch]$Voice
)

$bob = 'bottles of beer'
$wall = 'on the wall'
$todpia = 'Take one down, pass it around'

$tens = @(' ',' ','twenty','thirty','fourty','fifty','sixty','seventy','eighty','ninety')
$ones = @('zero','one','two','three','four','five','six','seven','eight','nine','ten','eleven','twelve', `
'thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen')

function Say-Number([int]$number){
    if($number-ge20){
        $numberword = $tens[($number-($number%10))/10]
        Write-Verbose "$numberword is greater than 20"
        if($number%10){
            $numberword += "-$($ones[$number%10])"
            Write-Verbose "$numberword is $number"
        }
    }
    else{
        $numberword = $ones[$number]
        Write-Verbose "$numberword is less than 20"
    }
    return $numberword
}

function Start-Sentence ([string]$word){
    return "$(([string]$word[0]).ToUpper())$($word.substring(1))"
}

function Read-Words ($phrase){
    $VoiceBox = New-Object -ComObject SAPI.SpVoice;
    $VoiceBox.Speak( [string]$phrase, 1 ) | out-null;
}

for($i=$BottlesOfBeerOnTheWall;$i-gt2;$i--){
    $bobotw = Say-Number $i
    Write-Host "$(Start-Sentence $bobotw) $bob $wall, $bobotw $bob."
    Write-Host "$todpia, $(Say-Number ($i-1)) $bob $wall."
    Write-Host ''
    if($Voice){
        Read-Words "$(Start-Sentence $bobotw) $bob $wall, $bobotw $bob. $todpia, $(Say-Number ($i-1)) $bob $wall."
        Start-Sleep -Seconds 9

    }
}
Write-Host "$(Start-Sentence (Say-Number 2)) $bob $wall, $(Say-Number 2) $bob."
Write-Host "$todpia, $(Say-Number 1) $($bob.Replace('bottles','bottle')) $wall."
Write-Host ""
Write-Host "$(Start-Sentence (Say-Number 1)) $($bob.Replace('bottles','bottle')) $($wall), $(Say-Number 1) $($bob.Replace('bottles','bottle'))."
Write-Host "$todpia, $(Say-Number 0) $bob $wall."
