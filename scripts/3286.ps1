function global:Format-Column {
################################################################
#.Synopsis
#  Formats incoming data to columns.
#.Description
#  It works similarly as Format-Wide but it works vertically. Format-Wide outputs
#  the data row by row, but Format-Columns outputs them column by column.
#.Parameter Property
#  Name of property to get from the object.
#  It may be 
#   -- string - name of property.
#   -- scriptblock
#   -- hashtable with keys 'Expression' (value is string=property name or scriptblock)
#      and 'FormatString' (used in -f operator)
#.Parameter Column
#  Number of columns to display.
#.Parameter Autosize
#  Automatically calculate the number of columns to display.
#.Parameter MaxColumn
#  Maximum number of columns to display if using Autosize.
#.Parameter Flow
#  The direction of flow to display items.
#.Parameter InputObject
#  Data to display.
#.Example
#  PS> 1..150 | Format-Column -Autosize
#.Example 
#  PS> Format-Column -Col 3 -Input 1..130
#.Example
#  PS> Get-Process | Format-Column -prop @{Expression='Handles'; FormatString='{0:00000}'} -auto
#.Example
#  PS> Get-Process | Format-Column -prop {$_.Handles} -auto
#.Notes
# Name: Format-Column
# Author: stej, http://twitter.com/stejcz
#  Version 0.1  - January 6, 2010 - stej
#  Version 0.2  - January 14, 2010 - stej
#               - ADDED parameter MaxColumn
#               - FIXED displaying collection of 1 item was incorrect
#  Version 0.3  - March 14, 2012 - By Jason Archer (This Version)
#               - ADDED parameter Flow
################################################################
    param(
        [Parameter(Position=0)][Object]$Property,
        [Parameter()][switch]$Autosize,
        [Parameter()][int]$Column,
        [Parameter()][int]$MaxColumn,
        [Parameter()][ValidateSet("Horizontal","Vertical")][String]$Flow = "Horizontal",
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][Object[]]$InputObject
    )

    begin   { [Object[]]$Values = @() }

    process { $Values += $InputObject }

    end {
        function ProcessValues {
            if ($Property -is [Hashtable]) {
                $exp = $Property.Expression
                if ($exp) {
                    if ($exp -is [string])          { $Values = $Values | % { $_.($exp) } }
                    elseif ($exp -is [scriptblock]) { $Values = $Values | % { & $exp $_} }
                    else                            { throw 'Invalid Expression value' }
                }
                if ($Property.FormatString) {
                    if ($Property.FormatString -is [string]) {
                        $Values = $Values | % { $Property.FormatString -f $_ }
                    } else {
                        throw 'Invalid format string'
                    }
                }
            }
            elseif ($Property -is [scriptblock]) { $Values = $Values | % { & $Property $_} }
            elseif ($Property -is [string]) {      $Values = $Values | % { $_.$Property } }
            elseif ($Property -ne $null) {         throw 'Invalid -Property type' }
            # in case there were some numbers, objects, etc., convert them to string
            $Values | % { $_.ToString() }
        }
        function Base($i) { [Math]::Floor($i) }
        function Max($i1, $i2) {  [Math]::Max($i1, $i2) }

        if (!$Column) { $Autosize = $true }
        $Values = ProcessValues

        $valuesCount = $values.Count
        if ($valuesCount -eq 1) {
            $Values | Out-Host
            return
        }

        # For some reason the console host doesn't use the last column and writes to new line
        $consoleWidth = $Host.UI.RawUI.MaxWindowSize.Width - 1
        $spaceWidthBetweenCols = 2

        # get length of the longest string
        $Values | ForEach-Object -Begin { [int]$maxLength = -1 } -Process { $maxLength = Max $maxLength $_.Length }

        # get count of columns if not provided
        if ($Autosize) {
            $Column = Max (Base ($consoleWidth/($maxLength+$spaceWidthBetweenCols))) 1
            $remainingSpace = $consoleWidth - $Column*($maxLength+$spaceWidthBetweenCols);
            if ($remainingSpace -ge $maxLength) { 
                $Column++ 
            }
            if ($MaxColumn -and $MaxColumn -lt $Column) {
                Write-Debug "Columns corrected to $MaxColumn (original: $Column)"
                $Column = $MaxColumn
            }
        }
        $countOfRows = [Math]::Ceiling($valuesCount / $Column)
        $maxPossibleLength = Base ($consoleWidth / $Column)

        # cut too long values, considers count of columns and space between them
        $Values = $Values | ForEach-Object { 
            if ($_.length -gt $maxPossibleLength) { $_.Remove($maxPossibleLength-2) + '..' }
            else { $_ }
        }

        #add empty values so that the values fill rectangle (2 dim array) without space
        if ($Column -gt 1) {
            $Values += (@('') * ($countOfRows * $Column - $valuesCount))
        }

        <#
        now we have values like this: 1, 2, 3, 4, 5, 6, 7, ''
        #>

        $formatString = (1..$Column | %{"{$($_-1),-$maxPossibleLength}"}) -join ''
        1..$countOfRows | ForEach-Object { 
            $r = $_ - 1
            if ($Flow -eq "Horizontal") {
                <# Display them like this:
                1 2 3 4
                5 6 7 ''
                #>
                $line = @(1..$Column | % { $Values[($r * $Column) + ($_ - 1)]})
            } else {
                <# Display them like this:
                1 3 5 7
                2 4 6 ''
                #>
                $line = @(1..$Column | % { $Values[$r + ($_ - 1) * $countOfRows]})
            }
            $formatString -f $line | Out-Host
        }
    }
}
