Param(
    [Parameter(Mandatory=$true)][string]$RootPath,
    [Parameter(Mandatory=$true)][string]$Destination,
    [Parameter(Mandatory=$true)][string]$LogPath
)

function Expand-ZipFile {
    Param(
        [Parameter(Mandatory=$true)][string]$File,
        [Parameter(Mandatory=$true)][string]$Path
    )
    [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
    [System.IO.Compression.ZipFile]::ExtractToDirectory($File, $Path)
}

function Write-Log {
    Param(
    [Parameter(Mandatory=$true, Position=1)][alias("P")][string]$Path,
    [Parameter(Mandatory=$true, Position=2)][alias("V")][string]$Value,
    [alias("D")][Switch]$AddDateTime,
    [alias("L")][Switch]$LogOnly
    )
    if($AddDateTime) {
        $Value = "$(Get-Date -Format MMddyyyy-hh:mm:ss) - $Value"
    }
    if(!$LogOnly) {
        Write-Host $Value
    }
    Add-Content -Path $Path -Value $Value
}

$subFolders = gci -Path $RootPath -Directory
foreach($subFolder in $subFolders) {
    $zipFiles = gci -Path $subFolder.FullName -Recurse -Include "*.zip" -File
    foreach($zipFile in $zipFiles) {
        $zipFilePath = $zipFile.FullName
        $pdfPath = ""
        if($Destination.EndsWith("\")) {
            $pdfPath = "$Destination$($zipFile.BaseName).pdf"
        }
        else {
            $pdfPath = "$Destination\$($zipFile.BaseName).pdf"
        }
        
        Write-Host "Extracting $zipFilePath"
        if(-Not (Test-Path -Path $pdfPath)) {
            try {
                Expand-ZipFile -File $zipFilePath -Path $Destination
            }
            catch {
                Write-Log -Path $LogPath -Value "$($zipFile.FullName) failed to extract."
            }
        }
        else {
            Write-Host "$pdfPath exists."
        }
    }
}
