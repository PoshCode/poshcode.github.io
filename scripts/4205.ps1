function Split-ByLength{
    <#
    .SYNOPSIS
    Splits string up by Split length.

    .DESCRIPTION
    Convert a string with a varying length of characters to an array formatted to a specific number of characters per item.

    .EXAMPLE
    Split-ByLength '012345678901234567890123456789123' -Split 10

    0123456789
    0123456789
    0123456789
    123

    .LINK
    http://stackoverflow.com/questions/17171531/powershell-string-to-array/17173367#17173367
    #>

    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string[]]$InputObject,

        [int]$Split=10
    )
    begin{}
    process{
        foreach($string in $InputObject){
            $len = $string.Length

            $repeat=[Math]::Floor($len/$Split)

            for($i=0;$i-lt$repeat;$i++){
                #Write-Output ($string[($i*$Split)..($i*$Split+$Split-1)])
                Write-Output $string.Substring($i*$Split,$Split)
            }
            if($remainder=$len%$split){
                #Write-Output ($string[($len-$remainder)..($len-1)])
                Write-Output $string.Substring($len-$remainder)
            }
        }        
    }
    end{}
}
