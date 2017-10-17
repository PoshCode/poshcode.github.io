################################################################################
# Set-FileLines.ps1 (V 1005)
# This script will maintain the PS Transcript file (default setting), or any 
# text file, at a fixed length, ie matching the number of lines entered.
# However, omitting the lines parameter will just remove any blank lines; and 
# using the -Blanks switch will remove blanks from the desired length. Can be 
# included in $profile.
# Examples:
#          Set-FileLines -File c:\Scripts\anyfile.txt  
#          Set-FileLines 1500 -Blanks
#          Set-FileLines 
# The author can be contacted via www.SeaStarDevelopmet.Bravehost.com
################################################################################
Param ([int]   $lines = 0,
       [String]$file = "$pwd\Transcript.txt",
       [Switch]$blanks)
	   
If ($file -notlike "*.txt") {
    [System.Media.SystemSounds]::Hand.Play()
    Write-Error "This script can only process .txt files"
    Exit 1
}
If (!(Test-Path $file)) {
    [System.Media.SystemSounds]::Hand.Play()
    Write-Error "File $file does not exist - please enter valid filename."
    Exit 1
}
[int]$count = 0
[int]$blankLines = 0
$encoding = 'Default'
$errorActionPreference = 'SilentlyContinue'
$content = (Get-Content $file)
If ($lines -eq  0) {                #A value of 0 lines will just remove blanks.
    [int]$extra = 1
    [int]$count = 1
    [switch]$blanks = $true          #Otherwise no blanks will be deleted below.
}
Else {
    $fileLength = ($content | Measure-Object -line)
    [int]$extra = $fileLength.Lines - $lines     #The number of lines to remove.
}
If ($extra -gt 0) {
    $date = "{0:g}" -f [DateTime]::Now
    $tempfile = [IO.Path]::GetTempFileName()
    Write-Output "$date Starting maintenance on file <$file>"
    If ($file -like "*transcript.txt") {
        $encoding = 'Unicode' 
        Stop-Transcript | Out-Null
        $status = $?                         #True if we are running transcript.
    }
    $content | ForEach-Object {
        $count += 1
        If($count -gt $extra) {                  #Ignore the first $extra lines.
            If (($blanks) -and ($_ -match '^\s*$')) {         #Skip blank lines.
 	        $blankLines++
            }
            Else {                                             #Create new file.
                $_ | Out-File $tempfile -encoding $encoding -Append -Force         
            }
        }
    }  #End ForEach
    Remove-Item $file -Force
    If (!$?) {
        [System.Media.SystemSounds]::Hand.Play()
        Write-Warning "$($error[0]) Application terminating." 
        Remove-Item $tempfile
        Break
    }
    Move-Item $tempfile -Destination $file -Force 
    If ($lines -eq 0) {                    #Only interested in blank lines here.
        $tag = "$blankLines blank lines removed."
    }
    ElseIf ($blanks) {
        $tag = "$extra lines removed (+ $blankLines blank)."
    }
    Else {
        $tag = "$extra lines removed."
    }
    If (($file -like "*transcript.txt") -and $status) {
        Start-Transcript -append -path $file -force | Out-Null
    }
    Write-Output "Maintenance of file completed: $tag"
}
$ErrorActionPreference = 'Continue'

