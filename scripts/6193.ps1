#Typewriter Text
function Write-Typewriter
{
<#
.Synopsis
   Make write-host text appear as if it is being typed on a typewriter
.DESCRIPTION
   Input text and if desired specify the write speed (25-250 milliseconds) for the text
.EXAMPLE
   Write-Typewriter "Hello world!"
.EXAMPLE
   Write-Typewriter "Hello world!" 250
.NOTES
   v1.0 - 2016-01-25 - Nathan Kasco
#>

    [CmdletBinding()]
    [Alias()]
    [OutputType([string])]

    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [alias("Name")]
        [string]
        $text,
        
        [Parameter(Mandatory=$false, Position=1)]
        [ValidateRange(25,250)]
        [int]
        $typeSpeed = 125
    )

    function sleep-host{
        Start-Sleep -Milliseconds $typeSpeed
    }

    #Cycle through letters
    $count = 0
    while($count -lt $text.Length){
        Write-Host $text.Chars($count) -NoNewline
        sleep-host
        $count++
    }
}
