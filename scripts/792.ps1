function Sort-ISE ()
{
 <# 
.SYNOPSIS 
    ISE Extension sort text starting at column $start comparing the next $length characters     
.DESCRIPTION 
    ISE Extension sort text starting at column $start comparing the next $length characters
    Leftmost column is column 1     
.NOTES 
    File Name  : Sort_ISE.ps1 
    Author     : Bernd Kriszio - http://pauerschell.blogspot.com/ 
    Requires   : PowerShell V2 CTP3 
.LINK 
    Script posted to: 
.EXAMPLE 
    Sort-ISE  1 10
#> 
#requires -version 2.0
    param (     
        [Parameter(Position = 0, Mandatory=$false)]
        [int]$start = 1,    
        [Parameter(Position = 1, Mandatory=$false)]
        [int]$length = -1    
    )     
    $newlines = @{}

    $editor = $psISE.CurrentOpenedFile.Editor
    $caretLine = $editor.CaretLine
    $caretColumn = $editor.CaretColumn
    $text = $editor.Text.Split("`n")
    foreach ($line in $text){
        $key = [string]::join("", $line[($start - 1)..($start - 1 + $length)])
        if ( $newlines[$key]  -ne $null) {
            $newlines[$key] =  $newlines[$key] + $line  
        }
        else {
            $newlines[$key] =  $line
        }
    }
    $Sortedkeys = $newlines.keys | sort
    $newtext = ''
    foreach ($key in $Sortedkeys){
        $newtext += $newlines[$key] 
    }
    $editor.Text = $newtext
}

