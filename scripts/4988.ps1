#requires -version 2.0
function Get-PEBrief {
  <#
    .EXAMPLE
        PS C:\Downloads>Get-PEBrief .\winrar-x64-501ru.exe -s

        CompanyName          :
        Magic                : PE32+
        ShellType            : exefile
        SubsystemVersion     : 5.02
        UninitializeDataSize : 0x0
        DllCharcteristics    : NxCompatible; TerminalSrvAware;
        Signed               : Valid
        FileVersion          :
        OSVersion            : 5.02
        ProductName          :
        FileName             : C:\Downloads\winrar-x64-501ru.exe
        TimeDateStamp        : 01.12.2013 14:08:37
        OriginalName         :
        Linker               : 9.00
        Characteristics      : LargeAddressAware; RelocationsStripped; Executable;
        FileDescription      :
        ProductVersion       :
        ImageVersion         : 0.00
        InitializedDataSize  : 0x12000
        InternalName         :
        AddressOfEntryPoint  : 0x21B6C
        NumberOfSections     : 5
        Copyright            :
        Machine              : AMD64
        Susbsystem           : WindowsGUI

        .text     0x0002AB12  0x00001000  0x0002AC00  0x00000400
        .rdata    0x00007AD3  0x0002C000  0x00007C00  0x0002B000
        .data     0x00022378  0x00034000  0x00001A00  0x00032C00
        .pdata    0x00002100  0x00057000  0x00002200  0x00034600
        .rsrc     0x00006688  0x0005A000  0x00006800  0x00036800
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName,
    
    [Parameter(Position=1)]
    [Switch]$Sections
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
      #info
      $ver = [Diagnostics.FileVersionInfo]::GetVersionInfo($FileName)
      #read structure
      $fs = [IO.File]::OpenRead($FileName)
      $buf = New-Object "Byte[]" 2048
      [void]$fs.Read($buf, 0, $buf.Length)
      #e_magic
      if ([String]::Join('', [Char[]]$buf[0..1]) -ne 'MZ') {
        throw (New-Object FormatException('Invalid DOS signature.'))
      }
      #e_lfanew
      $e_lfanew = 256 * $buf[0x3D] + $buf[0x3C]
      if ([String]::Join('', [Char[]]$buf[$e_lfanew..($e_lfanew + 3)]) -ne "PE`0`0") {
        throw (New-Object FormatException('Invalid file format.'))
      }
      #offset macro
      function private:get([Int32]$offset, [Switch]$band) {
        return $(switch ($band) {
          $false  { [BitConverter]::ToUInt32($buf, ($e_lfanew + $offset)) }
          default { [BitConverter]::ToUInt32($buf, ($e_lfanew + $offset)) -band 0xffff }
        })
      } #offset macro
      #sections pointer
      $ptr = $e_lfanew + (get 0x14 -b) + 24 #IMAGE_FILE_HEADER = 24 bytes
      #section macro
      function private:sget([Int32]$offset) {
        return ('0x{0:X8}' -f [BitConverter]::ToUInt32($buf, ($ptr + $offset)))
      } #offset macro
      #walking through sections
      if ($Sections) {
        $sec = $(for ($i = 0; $i -lt (get 0x6 -b); ++$i) {
          '{0}  {1}  {2}  {3}  {4}' -f [String]::Join('', [Char[]]$buf[$ptr..($ptr + 0x7)]), `
          (sget 0x8), (sget 0xC), (sget 0x10), (sget 0x14)
          $ptr += 40 #block of section = 40 bytes
        })
      }
      #result
      $PEBrief = New-Object PSObject -Property @{
        FileName = $FileName
        ShellType = (cmd /c assoc ([IO.FileInfo]$FileName).Extension).Split('=')[1]
        Signed = (Get-AuthenticodeSignature $FileName).Status
        CompanyName = $ver.CompanyName
        Copyright = $ver.LegalCopyright
        FileDescription = $ver.FileDescription
        FileVersion = $ver.FileVersion
        InternalName = $ver.InternalName
        OriginalName = $ver.OriginalFilename
        ProductName = $ver.ProductName
        ProductVersion = $ver.ProductVersion
        Machine = [Reflection.ImageFileMachine](get 0x4 -b)
        NumberOfSections = get 0x6 -b
        TimeDateStamp = [TimeZone]::CurrentTimeZone.ToLocalTime(
          ([DateTime]'1.1.1970').AddSeconds((get 0x8))
        )
        Characteristics = -join ($ifc.Keys | % {
          if (((get 0x16) -band $ifc[$_]) -eq $ifc[$_]) { $_ + '; ' }
        })
        Magic = switch((get 0x18 -b)){0x10B{'PE32'}0x20B{'PE32+'}}
        Linker = '{0}.{1:D2}' -f ((get 0x1A) -band 0xff), ((get 0x1B) -band 0xff)
        InitializedDataSize = '0x{0:X}' -f (get 0x20)
        UninitializeDataSize = '0x{0:X}' -f (get 0x24)
        AddressOfEntryPoint = '0x{0:X}' -f (get 0x28)
        OSVersion = '{0}.{1:D2}' -f ((get 0x40) -band 0xff), (get 0x42 -b)
        ImageVersion = '{0}.{1:D2}' -f ((get 0x44) -band 0xff), (get 0x46 -b)
        SubsystemVersion = '{0}.{1:D2}' -f ((get 0x48) -band 0xff), (get 0x4A -b)
        Susbsystem = -join ($iss.GetEnumerator() | % {
          if ((get 0x5C -b) -eq $_.Value) { $_.Key }
        })
        DllCharcteristics = -join ($idc.Keys | % {
          if (((get 0x5E) -band $idc[$_]) -eq $idc[$_]) { $_ + '; ' }
        })
      }
    }
    catch {
      Write-Host $_.Exception.Message -fo Red
    }
    finally {
      if ($fs -ne $null) { $fs.Close() }
    }
  }
  end {
    switch ($Sections) {$true{$PEBrief;$sec}default{$PEBrief}}
  }
}
