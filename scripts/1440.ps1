################################################################################
# Set-FileLines.ps1 (V 1003)
# This script will maintain the PS Transcript file (default setting), or any 
# text file, at a fixed length, ie matching the number of lines entered.
# However, setting no lines will just remove any blank lines; and including the
# -Blanks switch will do both. Can be included in $profile.
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
