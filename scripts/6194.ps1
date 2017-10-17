﻿#Typewriter Text
function Write-Typewriter
{
<#
.Synopsis
   Make write-host text appear as if it is being typed on a typewriter
.DESCRIPTION
   Input text and if desired specify the write speed (5-250 milliseconds) for the text
   Note: If $BlinkCursor = True you will clear-host by default
.EXAMPLE
   Write-Typewriter "Hello world!"
.EXAMPLE
   Write-Typewriter "Hello world!" 250
.EXAMPLE
   Write-Typewriter "Hello world!" 250 -ClearHost $true
.EXAMPLE
   Write-Typewriter "Hello world!" 250 -BlinkCursor $true -BlinkSpeed 500
.NOTES
   v1.0 - 2016-01-25 - Nathan Kasco
#>

    [OutputType([string])]

    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [alias("Name")]
        [string]
        $Text,
        
        [Parameter(Mandatory=$false, Position=1)]
        [ValidateRange(5,250)]
        [int]
        $TypeSpeed = 125,

        [Parameter(Mandatory=$false, Position=2)]
        [bool]
        $BlinkCursor = $false,

        [Parameter(Mandatory=$false, Position=3)]
        [int]
        $BlinkSpeed = 350,

        [Parameter(Mandatory=$false, Position=4)]
        [bool]
        $ClearHost = $false
    )

    function sleep-host{
        Start-Sleep -Milliseconds $typeSpeed
    }

    function blink-cursor{
        param(
            [parameter(mandatory=$false, position=0)]
            [bool]
            $last = $false
        )

        cls
        Write-Host $Text -NoNewline
        Write-Host "|"
        Start-Sleep -Milliseconds $BlinkSpeed

        cls
        #End on a new line
        if($last -eq $true)
        {
            Write-Host $Text
        }
        else{
            Write-Host $Text -NoNewline
        }
        Start-Sleep -Milliseconds 250
    }

    #Check to see if user activated blinking cursor after text output
    if($BlinkCursor -eq $true){
        $ClearHost = $true
    }

    #Cycle through letters
    $count = 0
    
    if($ClearHost -eq $true){
        cls
    }
    
    if($ClearHost -eq $false){

        while($count -lt $Text.Length){
            if($count -eq ($Text.Length - 1)){
                Write-Host $text.Chars($count)
            }
            else
            {
                Write-Host $text.Chars($count) -NoNewline
            }
            sleep-host
            $count++
        }
    }
    else{
        while($count -lt $text.Length){
            if($count -eq ($Text.Length - 1)){
                Write-Host $text.Chars($count)
            }
            else
            {
                Write-Host $text.Chars($count) -NoNewline
            }
            sleep-host
            $count++
        }
    }

    #Blinking cursor after text effect
    if($BlinkCursor -eq $true){
        $blinkCount = 0
        while($blinkCount -lt 4)
        {
            blink-cursor
            $blinkCount++
        }

        blink-cursor -last $true
    }
}
