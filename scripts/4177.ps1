
function New-RandomArray{
    #.SYNOPSIS
    #Generates a random number array.

    #.DESCRIPTION
    #Each element of the array is a random number between the Maximum and Minimum 
    #values.

    [cmdletbinding()]
    Param(

        #The amount of random number you want in your array.
        [Alias('ArrayLength','Count','Size')]
        [int]$Length=300,

        #Max value for each random number in the array.
        [int]$Maximum=1000,
        
        #Min value for each random number in the array.
        [int]$Minimum=-1000
    )

    Write-Verbose 'Generating random array ...'
    return (1..$Length | ForEach-Object {Get-Random -Maximum $Maximum -Minimum $Minimum})
}

function Get-MaxSumSubArray{
    #.SYNOPSIS
    #You are given an array with integers (both positive and negative) in any random order. Find the sub-array with the largest sum.
    
    #.DESCRIPTION
    #That's what it does.

    [cmdletbinding()]
    Param(
        #The array you want to use. If you don't have one I'll MAKE one!
        [int[]]$Array=(New-RandomArray -Verbose),

        #The length of the sub array.
        [int]$SubArrayLength=10
    )
    
    if($SubArrayLength -ge $Array.Count){
        throw "You are not finding a sub-array."
    }

    $BeginningIndexOfLastSubArray = $Array.Count - $SubArrayLength
    
    <# One line command
    0..$BeginningIndexOfLastSubArray |
    ForEach-Object {$array[$_..($_+$SubArrayLength-1)] | 
    Measure-Object -Sum} | 
    Sort-Object -Property Sum -Descending | 
    Select-Object -First 1
    #>

    $MaxSumSubArray = [PSCustomObject]@{Sum=[int]::MinValue;StartIndex=$null;EndIndex=$null}

    #Could make faster with jobs.
    for($i=0;$i-le$BeginningIndexOfLastSubArray;$i++){
        Write-Verbose "Calculating sub-array {$($array[$i..($i+$SubArrayLength-1)] -join ', ')}."
        $tmpsum = $array[$i..($i+$SubArrayLength-1)] | Measure-Object -Sum
        if($tmpsum.Sum -gt $MaxSumSubArray.Sum){
            $MaxSumSubArray.Sum = $tmpsum.Sum
            $MaxSumSubArray.StartIndex = $i
            $MaxSumSubArray.EndIndex = $i+$SubArrayLength-1
        }
    }

    return $MaxSumSubArray
}

Get-MaxSumSubArray -Verbose 
