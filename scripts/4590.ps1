$cleanDirectory = "C:\CLEAN"
$dirtyDirectory = "C:\DIRTY"
$monitoredFolders = "A", "B", "C"

foreach ($folder in $monitoredFolders) {
    foreach ($file in (gci $dirtyDirectory\$folder)) {
        if (Compare-Object $(gc $dirtyDirectory\$folder\$file) $(gc $cleanDirectory\$folder\$file)) {
            Write-Host "CONTENTS OF $dirtyDirectory\$folder\$file DO NOT MATCH $cleanDirectory\$folder\$file" -ForegroundColor RED
        }
    }
}
