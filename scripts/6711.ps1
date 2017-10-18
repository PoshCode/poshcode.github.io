function Get-RarContent {
  <#
    .SYNOPSIS
        Gets content of a compressed (RAR) file.
    .DESCRIPTION
        The main goal of this function to not use additional binary
        files such as WinRAR.exe and etc.
    .NOTES
        Author: greg zakharov
    .LINKS
        https://github.com/gregzakh/alt-ps/blob/master/tools/Get-RarContent.ps1
  #>
  param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({Test-Path $_})]
    [String]$Path
  )

  begin {
    # rar signature
    [Byte[]]$rar = 0x52, 0x61, 0x72, 0x21, 0x1A, 0x07, 0x00
  }
  process {
    try {
      $fs = [IO.File]::OpenRead((Convert-Path $Path))
      $br = New-Object IO.BinaryReader($fs)

      if (($cmp = Compare-Object ($br.ReadBytes(7)) $rar -PassThru)) {
        throw New-Object IO.IOException(
          'Specified file is nat a RAR archive, try another.'
        )
      }
      # MAIN_HEAD
      if (($mhd = $br.ReadBytes(7))[2] -ne 0x73) {
        throw New-Object IO.IOException(
          'Required structure MAIN_HEAD has not been found.'
        )
      }
      # move to the first entry
      [void]$fs.Seek((
        [BitConverter]::ToUInt16($mhd[5..6], 0) - 7
      ), [IO.SeekOrigin]::Current)
      # walk through all available items
      $content = while ($true) {
        $seg = $br.ReadBytes(7) # beginning of a block
        if (($bsz = [BitConverter]::ToUInt16($seg[5..6], 0)) -le 7) {
          break # nothing to read
        }

        $seg += $br.ReadBytes($bsz - 7) # whole block
        # check that current entry is a file system object
        if ($seg[2] -eq 0x74) {
          [void]$fs.Seek((
            $cmp = [BitConverter]::ToUInt32($seg[7..10], 0) # compressed
          ), [IO.SeekOrigin]::Current)

          if ((
            $atr = [BitConverter]::ToUInt32($seg[28..31], 0)
          ) -band 0x10 -or $atr -band 0x4000) {
            continue # do you really need to see paths of folders?
          }

          New-Object PSObject -Property @{
            Name = -join [Char[]]$seg[32..(
              32 + [BitConverter]::ToUInt16($seg[26..27], 0
            ) - 1)]
            Cmpd = $cmp
            Size = [BitConverter]::ToUInt32($seg[11..14], 0)
            Attr = -join (([IO.FileAttributes]$atr).ToString().Split(
              ', ', [StringSplitOptions]::RemoveEmptyEntries
            ) | ForEach-Object { $_[0] })
            #Crc32 = '0x{0:X}' -f ([BitConverter]::ToUInt32($seg[16..19], 0))
          }
        }
        else {
          if ([BitConverter]::ToUInt16($seg[3..4], 0) -band 0x8000) {
            [void]$fs.Seek([BitConverter]::ToUInt32(
              $seg[7..10], 0), [IO.SeekOrigin]::Current
            )
          }
        }
      } # while
    }
    catch { Write-Warning $_ }
    finally {
      if ($br) { $br.Close() }
      if ($fs) { $fs.Dispose() }
    }
  }
  end {
    if ($content) {
      $content | Select-Object Attr, Size, Cmpd, Name |
      Format-Table -AutoSize
    }
  }
}
