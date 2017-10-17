#extract unique extentions in specified path
[Regex]::Matches((gci -ea 0 (Read-Host 'Enter path')), '\.\w+', 'IgnoreCase') | % {$_.Value} | select -Unique
