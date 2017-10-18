param($sqlserver, $filepath)

#Note: Uses Changeset 59378 or higher of SQLPSX SQLServer module http://sqlpsx.codeplex.com/SourceControl/changeset/view/58378#564810
#Added FileListOnly option to Invoke-SqlRestore. The option will be included in releases after 2.3.1

import-module sqlserver -force


$server = get-sqlserver $sqlserver

$filepath = Resolve-Path $filepath | select -ExpandProperty Path
$dbname = Get-ChildItem $filePath | select -ExpandProperty basename

$dataPath = Get-SqlDefaultDir -sqlserver $server -dirtype Data
$logPath = Get-SqlDefaultDir -sqlserver $server -dirtype Log

$relocateFiles = @{}
Invoke-SqlRestore -sqlserver $server  -filepath $filepath -fileListOnly | foreach { `
    if ($_.Type -eq 'L')
    { $physicalName = "$logPath\{0}" -f [system.io.path]::GetFileName("$($_.PhysicalName)") }
    else
    { $physicalName = "$dataPath\{0}" -f [system.io.path]::GetFileName("$($_.PhysicalName)") }
    $relocateFiles.Add("$($_.LogicalName)", "$physicalName")
}

$server.KillAllProcesses($dbname)

Invoke-SqlRestore -sqlserver $server -dbname $dbname -filepath $filepath -relocatefiles $relocateFiles -Verbose -force
