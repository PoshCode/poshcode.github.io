function SearchZIPfiles {
<#
.SYNOPSIS 
Search for (filename) strings inside compressed ZIP or RAR files (V2.2).
.DESCRIPTION
In any directory containing a large number of ZIP/RAR compressed Web Page files 
this procedure will search each individual file name for simple text strings, 
listing both the source RAR/ZIP file and the individual file name containing
the string. The relevant RAR/ZIP can then be subsequently opened in the usual
way.
Using the '-Table' switch will show the results with the Out-GridView display.
.EXAMPLE
extract -find 'library' -path d:\scripts

Searching for 'library' - please wait... (Use CTRL+C to quit)
[Editor.zip] File: Windows 7 Library Procedures.mht
[Editor.rar] File: My Library collection from 1974 Idi Amin.html
[Test2.rar] File: Playlists from library - Windows 7 Forums.mht
[Test3.rar] File: Module library functions UserGroup.pdf
A total of 4 matches for 'library' found in folder 'D:\Scripts'.
.EXAMPLE
extract -find 'backup' -path desktop

Searching for 'backup' - please wait... (Use CTRL+C to quit)
[Web.zip] File: How To Backup User and System Files.mht
[Pages.rar] File: Create an Image Backup.pdf
A total of 2 matches for 'backup' found in folder 'C:\Users\Sam\Desktop'.
.NOTES
The first step will find any lines containing the selected pattern (which can
be anywhere in the line). Each of these lines will then be split into 2 
headings: Source and Filename.
Note that there may be the odd occasion where a 'non-readable' character in the
returned string slips through the net! 
.LINK
Web Address Http://www.SeaStarDevelopment.BraveHost.com
#>
   [CmdletBinding()]
   param([string][string][Parameter(Mandatory=$true)]$Find,
         [string][ValidateNotNullOrEmpty()]$path = $pwd,
         [switch][alias("GRIDVIEW")]$table)

   [int]$count = 0
   if ($path -like 'desk*') {
      $path = Join-Path $home 'desktop\*'
   }
   else {
      $xpath = Join-Path $path '*' -ea 0
      if (!($?) -or !(Test-Path $path)) {
         Write-Warning "Path '$path' is invalid - resubmit"
         return
      }
      $path = $xpath
   }
   $folder = $path.Replace('*','')
   $lines = @{}
   $regex = '(?s)^(?<zip>.+?\.(?:zip|rar)):(?:\d+):.*\\(?<file>.*\.(mht|html?|pdf))(.*)$'

   Get-ChildItem $path -include '*.rar','*.zip' |
      Select-String -SimpleMatch -Pattern $find |
         foreach-Object `
            -begin { Write-Host "Searching for '$find' - please wait... (Use CTRL+C to quit)" } `
            -process {
                $_ = $_ -replace '/','\'
                if ( $_ -match $regex ) {
                   $source = $matches.zip -replace [regex]::Escape($folder)
                   $file   = $matches.file
                   $file = $file -replace '\s+',' '         #Single space words.
                   $file = $file -replace '\p{S}',' '   #Remove some 'Dingbats'.
                   if ($table) {
                      $key = "{0:D4}" -f $count
                      $lines["$key $source"] = $file       #Create a unique key.
                   }
                   else {
                      Write-Host "[$source] File: $file"
                   }
                   $count++ 
                }
            } `
            -end { 
                $title = "A total of $($count) matches for '$find' found in host folder '$($path.Replace('\*',''))'."
                if ($table -and $lines.count -gt 0) {        
                   $lines.GetEnumerator() | 
                      Select-Object @{name = 'Source';expression = {$_.Key.SubString(5)}},
                                    @{name = 'File'  ;expression = {$_.Value}} |
                         Sort-Object File |
                            Out-GridView -Title $title
                }
                else {
                   Write-Host $title
                } 
            }
} #End function.

New-Alias extract SearchZIPfiles    -Description 'Find Web files inside ZIP/RAR'
Export-ModuleMember -Function SearchZIPfiles -Alias Extract
