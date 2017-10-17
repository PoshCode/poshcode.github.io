# Create the transcript file and start the transcript
new-item -path ([Environment]::GetFolderPath('MyDocuments')) -name "PowerShell_Transcripts" -type directory -ea "silentlycontinue"
$transcriptFolder = [Environment]::GetFolderPath('MyDocuments') + "\PowerShell_Transcripts\"
$filedate = get-date -format yyyyMMdd.hhmmss
$transcriptfile = $transcriptFolder + $filedate + ".log"
start-transcript $transcriptfile -noClobber -append
