$SourcePath = 'C:\\Admin\\ScriptTest\\SourceFolder'
$destPath = 'C:\Admin\ScriptTest\DestinationFolder'
foreach ($file in Get-ChildItem $SourcePath -Recurse -Filter TestFile.txt){
    $destDir = $file.DirectoryName -replace $sourcePath,$destPath
    $null = mkdir $destDir -force
    Copy-Item -Path $file.fullname -Destination $destDir
}
