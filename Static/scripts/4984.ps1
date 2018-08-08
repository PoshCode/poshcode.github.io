#requires -version 2.0
function Get-PEDump {
  <#
    .EXAMPLE
        PS C:\>Get-PEDump whois.exe
        Machine              : I386
        Characteristics      : RelocationsStripped; Supports32Bit; Executable;
        Module               : C:\whois.exe
        Magic                : PE32
        OSVersion            : 5.00
        Subsystem            : WindowsCUI
        TimeDataStamp        : 30.08.2012 22:07:23
        LinkerVersion        : 9.00
        SizeOfCode           : 0x1A800
        SizeOfOptionalHeader : 0xE0
        DllCharacteristics   : TerminalSrvAware;
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName
  )
  
  begin {
    $FileName = cvpa $FileName
    #IMAGE_FILE_CHARACTERISTICS
    $ifc = @{}
    $ifc['RelocationsStripped']      = 0x0001
    $ifc['Executable']               = 0x0002
    $ifc['LineNumbersStripped']      = 0x0004
    $ifc['SymbolsStripped']          = 0x0008
    $ifc['AggressiveTrimWorkingSet'] = 0x0010
    $ifc['LargeAddressAware']        = 0x0020
    $ifc['Supports16Bit']            = 0x0040
    $ifc['ReservedBytesWo']          = 0x0080
    $ifc['Supports32Bit']            = 0x0100
    $ifc['DebugInfoStripped']        = 0x0200
    $ifc['RunFromSwapIfInRmvbl']     = 0x0400
    $ifc['RunFromSwapIfInNetwrk']    = 0x0800
    $ifc['SystemFile']               = 0x1000
    $ifc['Dll']                      = 0x2000
    $ifc['OnlyFroSingleCoreProc']    = 0x4000
    $ifc['BytesOfWordReserved']      = 0x8000
    #IMAGE_SUBSYSTEM
    $iss = @{}
    $iss['Unknown']           = 0x00
    $iss['Native']            = 0x01
    $iss['WindowsGUI']        = 0x02
    $iss['WindowsCUI']        = 0x03
    $iss['OS2_CUI']           = 0x04
    $iss['POSIX_CUI']         = 0x05
    $iss['NativeWindows']     = 0x06
    $iss['WindowsCE_CUI']     = 0x07
    $iss['EFIApplication']    = 0x08
    $iss['EFIBootServiceDrv'] = 0x09
    $iss['EFIRuntimeDrv']     = 0x0A
    $iss['EFIRom']            = 0x0B
    $iss['XBox']              = 0x0C
    $iss['WinBootApp']        = 0x10
    #IMAGE_DLL_CHARACTERISTICS
    $idc = @{}
    $idc['Native']           = 0x0000
    $idc['Res0']             = 0x0001
    $idc['Res1']             = 0x0002
    $idc['Res2']             = 0x0004
    $idc['Res3']             = 0x0008
    $idc['DynamicBase']      = 0x0040
    $idc['ForceItegrity']    = 0x0080
    $idc['NxCompatible']     = 0x0100
    $idc['NoIsolation']      = 0x0200
    $idc['NoSEH']            = 0x0400
    $idc['NoBind']           = 0x0800
    $idc['Res4']             = 0x1000
    $idc['WDMDriver']        = 0x2000
    $idc['TerminalSrvAware'] = 0x8000
  }
  process {
    try {
      $fs = [IO.File]::OpenRead($FileName)
      $buf = New-Object "Byte[]" 1024
      [void]$fs.Read($buf, 0, $buf.Length)
      #e_magic
      if ([String]::Join('', [Char[]]$buf[0..1]) -ne 'MZ') {
        throw (New-Object FormatException("Invalid DOS signature."))
      }
      #e_lfanew
      $e_lfanew = 256 * $buf[0x3D] + $buf[0x3C]
      if ([String]::Join('', [Char[]]$buf[$e_lfanew..($e_lfanew + 3)]) -ne "PE`0`0") {
        throw (New-Object FormatException("Invalid file format."))
      }
      #extract
      function private:get([Int32]$offset, [Switch]$ret) {
        return $(switch ($ret) {
          $false  { [BitConverter]::ToInt32($buf, ($e_lfanew + $offset)) }
          default { [BitConverter]::ToInt32($buf, ($e_lfanew + $offset)) -band 0xffff }
        })
      }
      #output
      $PEDump = New-Object PSObject -Property @{
        Module = $FileName
        Magic = $(if ((get 0x18 -r) -eq 0x10B) {'PE32'} else {'PE32+'})
        Machine = [Reflection.ImageFileMachine](get 0x4 -r)
        TimeDataStamp = [TimeZone]::CurrentTimeZone.ToLocalTime(
          ([DateTime]'1.1.1970').AddSeconds((get 0x8))
        )
        Characteristics = -join ($ifc.Keys | % {
          if (((get 0x16) -band $ifc[$_]) -eq $ifc[$_]) {
            $_ + '; '
          }
        })
        LinkerVersion = '{0}.{1:D2}' -f ((get 0x1A) -band 0xff), (get 0x1B -r)
        SizeOfOptionalHeader = '0x{0:X}' -f (get 0x14 -r)
        SizeOfCode = '0x{0:X}' -f (get 0x1C)
        OSVersion = '{0}.{1:D2}' -f (get 0x40 -r), (get 0x42 -r)
        Subsystem = -join ($iss.GetEnumerator() | % {
          if ((get 0x5C -r) -eq $_.Value) { $_.Key }
        })
        DllCharacteristics = -join ($idc.Keys | % {
          if (((get 0x5E) -band $idc[$_]) -eq $idc[$_]) {
            $_ + '; '
          }
        })
      }
      $PEDump.PSObject.TypeNames.Insert(0, 'PEDump')
    }
    catch {
      Write-Host $_.Exception.Message -fo Red
    }
    finally {
      if ($fs -ne $null) { $fs.Close() }
    }
  }
  end { $PEDump }
}
