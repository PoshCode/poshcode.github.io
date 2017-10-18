################################################################################
# Set-FileLines.ps1
# This script will maintain the PS Transcript file, or any text file, at a fixed
# length and can be used to prevent such files from becoming too large, with the
# option of removing any blank lines.  Defaults to 10000 lines and can be placed
# in $profile.
# Setting lines to 0 will just remove any blank lines from the file and, in this
# case, the -Blanks switch is not necessary.
# Examples:
#          Set-FileLines 1500 c:\Scripts\Logfile.txt  
#          Set-FileLines 0 c:\scripts\anyfile.txt
#          Set-FileLines 3000 -Blanks
# The author can be contacted via www.SeaStarDevelopmet.Bravehost.com
################################################################################
Param ([int]   $lines = 10000,
       [String]$file = "$pwd\Transcript.txt",
	   [Switch]$blanks)
	   
If ($file -notlike "*.txt") {
	[System.Media.SystemSounds]::Hand.Play()
	Write-Error "This script can only process .txt files"
	Exit 1
}
If (!(Test-Path $file)) {
	[System.Media.SystemSounds]::Hand.Play()
	Write-Error "File $file does not exist"
	Exit 1
}
[int]$count = 0
[int]$blankLines = 0
$errorActionPreference = 'SilentlyContinue'
$content = (Get-Content $file)
If ($lines -eq  0) {            #Input 0 lines to have just blank lines removed.
	[int]$extra = 1
	[int]$count = 1
	[switch]$blanks = $true          #Otherwise no blanks will be deleted below.
}
Else {
	$fileLength = ($content | Measure-Object -line)
	[int]$extra = $fileLength.Lines - $lines     #The number of lines to remove.
}
If ($extra -gt 0) {
    $tempfile = [IO.Path]::GetTempFileName()
	Write-Output "Starting maintenance on file <$file>"
	$content | ForEach-Object {
    	$count += 1
  		If($count -gt $extra) {                  #Ignore the first $extra lines.
			If (($blanks) -and ($_ -match '^\s*$')) {         #Skip blank lines.
				$blankLines++
			}
			Else {
		    	$_ | Out-File $tempfile -Append -Force         #Create new file.
			}
		}
	}
	If ($file -like "*transcript.txt") { 
		Stop-Transcript | Out-Null
	}
	Remove-Item $file
	Move-Item $tempfile -Destination $file
	If ($lines -eq 0) {                    #Only interested in blank lines here.
		$tag = "$blankLines blank lines removed."
	}
	ElseIf ($blanks) {
		$tag = "$extra lines removed (+ $blankLines blank)."
	}
	Else {                                       #Not interested in blank lines.
		$tag = "$extra lines removed."
	}
	If ($file -like "*transcript.txt") {
		Start-Transcript -append -path $file -force | Out-Null
	}
	Write-Output "Maintenance of file completed: $tag"
}
$ErrorActionPreference = 'Continue'
