function Show-LineArrayStructure ($lines)
{
    $len = $lines.length
    "Type is:         $($lines.gettype().Name)"
    "Number of lines: $len"
    for ($i = 0; $i -lt $len; $i++)
    {
        "$($i + 1). Line: length $($lines[$i].length) >$($lines[$i])<"
    }
    '' 
    
} 


    $text = "abc`r`nefg`r`n"


#     $text
#     $text.length

    $lines = $text.Split("`n")
    Show-LineArrayStructure $lines
    

    $lines2 = $text.Split("`r`n")
    Show-LineArrayStructure $lines2

    $lines3 = $([Regex]::Split($text,"`r`n" ))
    Show-LineArrayStructure $lines3
    
    $lines4 = $text -split "`n"
    Show-LineArrayStructure $lines4

   # best method
   $lines5 = $text -split "`r`n"
    Show-LineArrayStructure $lines5

    # even better proposed by Jaycul in comment on
    # http://pauerschell.blogspot.com/2009/02/ise-extension-basics-splitting-text-to.html
    $lines6 =$text.Split([string[]]"`r`n", [StringSplitOptions]::None)
    Show-LineArrayStructure $lines6

