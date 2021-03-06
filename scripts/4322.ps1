param(
    # The name of the file to edit.
    $TargetFile,

    # The position in the target file to start writing at.
    $TargetOffset,
    
    # The name of the file to read from.
    [Parameter(ParameterSetName="Copy", Mandatory = $true)]
    $SourceFile,

    # The position in the source file to read from.
    [Parameter(ParameterSetName="Copy")]
    $SourceOffset = 0, 

    # The number of bytes to copy
    [Parameter(ParameterSetName="Copy", Mandatory = $true)]
    $ByteCount,

    # The array of new bytes to write, starting at $TargetOffset
    [Parameter(ParameterSetName="Input")]
    [Byte[]]$NewBytes
)

$TargetFile = (Resolve-Path $TargetFile).Path
# prove it's a filesytem file
if([System.IO.File]::Exists($TargetFile)) {

    $Target = $null
    try {
        if(!$NewBytes) {
            $NewBytes = New-Object Byte[] $ByteCount
            $Source = [System.IO.File]::Open($SourceFile, [System.IO.FileMode]::Open, "Read")
            $Source.Position = $SourceOffset
            $count = $Source.Read($NewBytes, 0, $ByteCount)
            if($count -ne $ByteCount) {
                Write-Error "Only read $count instead of $ByteCount from source"
            }
        }

        $Target = [System.IO.File]::Open($TargetFile, [System.IO.FileMode]::Open, "Write")
        $Target.Position = $TargetOffset
        $Target.Write($NewBytes, 0, $NewBytes.Length)
        
    } finally {
        if($Source -ne $null) {
            try {
                $Source.Close()
                $Source = $null
            } catch {}
        }
        if($Target -ne $null) {
            try {
                $Target.Close()
                $Target = $null
            } catch {}
        }
    }
} else {
    Write-Error "$Filename does not exist"
}
