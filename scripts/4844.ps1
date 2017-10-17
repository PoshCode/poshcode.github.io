#requires -version 2.0
Set-Alias tail Get-FileTail

function Get-FileTail {
  <#
    .NOTES
        Author: greg zakharov
  #>
  [CmdletBinding(DefaultParameterSetName="FileName", SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName,
    
    [Parameter(Position=1)]
    [ValidateRange(1, 65535)]
    [UInt16]$NumberOfLines = 10,
    
    [Parameter(Position=2)]
    [Text.Encoding]$Encoding = [Text.Encoding]::Default,
    
    [Parameter(Position=3)]
    [String]$Delims = "`r`n"
  )
  
  begin {
    $FileName = cvpa $FileName
    
    function get([String]$path, [Int64]$tokens, [Text.Encoding]$enc, [String]$delims) {
      [Int32]$szChar = $enc.GetByteCount("`n")
      [Byte[]]$buff = $enc.GetBytes($delims)
      
      try {
        $fs = New-Object IO.FileStream($path, [IO.FileMode]::Open, [IO.FileAccess]::Read)
        [Int64]$tknCount = 0
        [Int64]$endReads = $fs.Length / $szChar
        
        for ([Int64]$pos = $szChar; $pos -lt $endReads; $pos += $szChar) {
          [void]$fs.Seek(-$pos, [IO.SeekOrigin]::End)
          [void]$fs.Read($buff, 0, $buff.Length)
          
          if ($enc.GetString($buff) -eq $delims) {
            $tknCount++
            if ($tknCount -eq $tokens) {
              [Byte[]]$retBuff = New-Object "Byte[]" ($fs.Length - $fs.Position)
              [void]$fs.Read($retBuff, 0, $retBuff.Length)
              return $enc.GetString($retBuff)
            }
          }
        }
        
        $fs.Seek(0, [IO.SeekOrigin]::Begin)
        $buff = New-Object "Byte[]" $fs.Length
        [void]$fs.Read($buff, 0, $buff.Length)
        return $enc.GetString($buff)
      }
      finally {
        if ($fs -ne $null) {$fs.Close()}
      }
    }
  }
  process {
    if ($PSCmdlet.ShouldProcess($FileName, "Reads last $($NumberOfLines) strings of")) {
      get $FileName $NumberOfLines $Encoding $Delims
    }
  }
  end {}
}
