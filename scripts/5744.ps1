Function Invoke-FolderCompression
{
    Param
    (
        [Parameter(Position=0, Mandatory, ValueFromPipeline)]
        [string]$Path,
        [Parameter(Position=1)]
        [switch]$Uncompress,
        [Parameter(Position=2)]
        [switch]$Recurse,
        [Parameter(Position=3)]
        [switch]$Background
    )

    $target = ($Path | Resolve-Path -ea 'Stop').Path

    if ($Uncompress) { $action = 'UncompressEx'} else { $action = 'CompressEx' }

    $objPath = [Management.ManagementPath]"\\.\root\cimv2:Win32_Directory.Name='$target'"
    $dir = New-Object -TypeName 'Management.ManagementObject' -ArgumentList $objPath
    $objClass = New-Object -TypeName 'Management.ManagementClass' -ArgumentList $objPath.ClassName
    $parameters = $objClass.GetMethodParameters($action)
    $parameters.Recursive = $Recurse

    if ($Background)
    {
        $observer = New-Object -TypeName 'Management.ManagementOperationObserver'
        $dir.InvokeMethod($observer, $action, $parameters, $null)
    }
}

