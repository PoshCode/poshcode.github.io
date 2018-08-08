# Write a blank new line for easy, spaced reading
Write-Host

# Full file path location of source file
$SourceFilePath = Read-Host "Source File Path"

# Target directory to compare source file to
$TargetDirectory = Read-Host "Target Directory"

Write-Host

# Prompt user whether they want a prompt for every match before overwriting
$Prompt = Read-Host "Prompt before overwriting (Y or N)?"

# Default confirmation prompt to [Y]es if input is invalid
$Prompt = $Prompt.ToUpper()
if ($Prompt -eq "" -or ($Prompt -ne "Y" -and $Prompt -ne "N")) {
	$Prompt = "Y"
}

# Extract just the file name from source file path
$SourceFileName = $SourceFilePath.Substring($SourceFilePath.LastIndexOf('\')+1)

# Get source file modified date to compare to other files
$SourceFileModified = (Get-Item $SourceFilePath).LastWriteTime

Write-Host
Write-Host "Source file modified date is $($SourceFileModified)"
Write-Host

# Recursively find matches
$matches = Get-ChildItem -Path $TargetDirectory -Filter $SourceFileName -Recurse |
	Where { $_.LastWriteTime -lt $SourceFileModified } |
	Foreach-object {
		if ($Prompt -eq "N") {
			Copy-Item $SourceFilePath $_.FullName.Substring(0, $_.FullName.LastIndexOf('\'))
			Write-Host "$($_.FullName) [$($_.LastWriteTime)] [updated]"
		} else {
			Write-Host "Match found > $($_.FullName) [$($_.LastWriteTime)]"
			Copy-Item -Confirm $SourceFilePath $_.FullName.Substring(0, $_.FullName.LastIndexOf('\'))
		}
	}

Write-Host
