# Daniel Cheng

#$VerbosePreference = 'continue'
$VerbosePreference = 'silent'

filter ColorPattern {
    param ([object]$colors, [switch]$SimpleMatch)
    [string]$line = $_

    $collection = New-Object 'System.Collections.Generic.SortedDictionary[int, pscustomobject]'
    $RegexOptions = [Text.RegularExpressions.RegexOptions]::IgnoreCase.value__ + [Text.RegularExpressions.RegexOptions]::Singleline.value__

    if ($SimpleMatch){
        $patternMatches = $colors.keys | % {[regex]::Escape($_)}
        $reference = 'Value'
    } else {
        $patternMatches = $colors.keys
        $reference = 'Pattern'
    }

    # detect RegEx matches and add to collection object
    Write-Verbose "'$line'"

    $measureparsing_match = (Measure-Command {
        foreach ($pattern in $patternMatches){
            Write-Verbose "regex pattern: $pattern"
            foreach ($match in ([regex]::Matches($line, $pattern, $RegexOptions))){ # lazy matching
                Write-Verbose "`tmatch index: $($match.Index) length: $($match.length)"

                $currentset = ($match.Index)..($match.Index + $match.length - 1)
                Write-Verbose "`tcurrent set: $currentset"

                if (-not [bool]$collection.Count){
                    Write-Verbose "`t`tindex: $($match.Index) value: $($match.value) (inital add)"
                    [void]$collection.Add($match.Index, [PSCustomObject]@{Length = $match.Length; Value = $match.Value; Pattern = $pattern; Range = $currentset})
                } else {
                    (,$collection.Values) | % {
                        $currentRange = $_.range
                        $intersect = Compare-Object -PassThru $currentset $currentRange -IncludeEqual -ExcludeDifferent
                        if ($intersect){
                            Write-Verbose "`t`tintersect: $([string]($intersect | % {[string]::Concat($_)})) (skipped)"

                            $nonintersect = Compare-Object -PassThru $currentset $intersect
                            Write-Verbose "`t`tnonintersect: $([string]($nonintersect | % {[string]::Concat($_)}))"

                            $nonintersect | % {
                                if ($currentRange -notcontains $_){
                                    Write-Verbose "`t`tindex: $_ value: $($line[$_]) (adding intersect-fallout)"
                                    [void]$collection.Add($_, [PSCustomObject]@{Length = $_.Length; Value = $line[$_]; Pattern = $pattern; Range = $currentset})
                                } else {
                                    Write-Verbose "`t`t`tindex: $_ value: $($line[$_]) (skipped intersect-fallout)"
                                }
                            }
                        } else {
                            Write-Verbose "`t`tindex: $($match.index) value: $($match.value) (adding nonintersect)"
                            [void]$collection.Add($match.Index, [PSCustomObject]@{Length = $match.Length; Value = $match.Value; Pattern = $pattern; Range = $currentset})
                        }
                    } # end values
                } #end if
            } # end matching
        } # end pattern
    }).TotalMilliseconds

    $measureparsing_nonmatch = (Measure-Command {
        if ([bool]$collection.count){ # if there are no matches, skip!
            Compare-Object -PassThru `
            -ReferenceObject (
                $collection.Keys | % { # all matched keys and their lengths
                    $word = $collection.item($_)
                    $currentlength = ($word.value).length
                    ($_..($_ + ($currentlength - 1)))
                }) `
            -DifferenceObject (0..($line.Length - 1)) | # entire line
                % {[void]$collection.Add($_, [PSCustomObject]@{Length = $_.length; Value = $line[$_]})} # add non matches to collection
        }
    }).TotalMilliseconds

    Write-Verbose "match: $measureparsing_match ms. VS nonmatch: $measureparsing_nonmatch ms."

    $collection.keys | % {
        $word = $collection.item($_)
        if ($word.pattern){
            if ($colors.ContainsKey($word.$reference)){
                $color = @{
                    ForegroundColor = $colors[$word.$reference].ForegroundColor;
                    BackgroundColor = $colors[$word.$reference].BackgroundColor
                }
                if ($word.value){
                    Write-Host -NoNewline $([string]::Concat($word.value)) @color
                }
            }
        } else {
            Write-Host -NoNewline $([string]::Concat($word.value))
        }
    }
    Write-Host # needed for line feed
}

$Patterns = [ordered]@{
    # higher in list takes precendence
    'stopped' = @{ForegroundColor = 'Red'; BackgroundColor='DarkRed'}
    'running' = @{ForegroundColor = 'Green'; BackgroundColor='DarkGreen'}
    'paused' = @{ForegroundColor = 'Yellow'; BackgroundColor='DarkYellow'}
    0 = @{ForegroundColor = 'White'; BackgroundColor='Gray'}
    '\d+' = @{ForegroundColor = 'Gray'; BackgroundColor='Black'}
    '\.' = @{ForegroundColor = 'Magenta'; BackgroundColor='DarkMagenta'}
    '(a|e|i|o|u)' = @{ForegroundColor = 'Yellow'; BackgroundColor='DarkYellow'}
    '\w+' = @{ForegroundColor = 'Cyan'; BackgroundColor='DarkCyan'}

}

# strongly typed collection.. we could probably do this better..
$colorCollection = New-Object 'system.collections.generic.dictionary[string, hashtable]'([StringComparer]::OrdinalIgnoreCase) # Ordinal
$Patterns.GetEnumerator() | % {[void]$colorCollection.Add($_.Name, $_.Value)}

Get-Service | Out-String -Stream | ColorPattern -colors $colorCollection
#Get-Service | Out-String -Stream | ColorPattern -colors $colorCollection -SimpleMatch
