Param(
    [Parameter(Mandatory=$true)][string]$RootPath,
    [Parameter(Mandatory=$true)][string]$Destination
)

function Expand-ZipFile {
    Param(
        [Parameter(Mandatory=$true)][string]$File,
        [Parameter(Mandatory=$true)][string]$Path
    )
    [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
    [System.IO.Compression.ZipFile]::ExtractToDirectory($File, $Path)
}

$subFolders = gci -Path $RootPath -Directory
foreach($subFolder in $subFolders) {
    $zipFiles = gci -Path $subFolder.FullName -Recurse -Include "*.zip" -File
    foreach($zipFile in $zipFiles) {
        $zipFilePath = $zipFile.FullName
        Write-Host "Extracting $zipFilePath"
        Expand-ZipFile -File $zipFilePath -Path $Destination
    }
}
