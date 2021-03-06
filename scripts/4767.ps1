function Get-PEHeader {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [String]$FileName
  )
  
  begin {
    function Get-Class([String]$Assembly, [String]$Class) {
      return ([AppDomain]::CurrentDomain.GetAssemblies() | ? {
        $_.FullName -match $Assembly
      }).GetType($Class)
    }
    
    function Get-Struct([Object]$Base, [String]$Name) {
      return [Activator]::CreateInstance(
        $Base.GetNestedType($Name, [Reflection.BindingFlags]32)
      )
    }
    
    function Trace-Binary([IO.BinaryReader]$Reader, [Object]$Data) {
      $bytes = $Reader.ReadBytes(
        [Runtime.InteropServices.Marshal]::SizeOf($Data)
      )
      $hndl = [Runtime.InteropServices.GCHandle]::Alloc(
        $bytes, [Runtime.InteropServices.GCHandleType]::Pinned
      )
      $struct = [Runtime.InteropServices.Marshal]::PtrToStructure(
        $hndl.AddrOfPinnedObject(),  $Data.GetType()
      )
      $hndl.Free()
      
      return $struct
    }
    
    function Trace-Stamp([Object]$Stamp) {
      return [TimeZone]::CurrentTimeZone.ToLocalTime(
        ([DateTime]'1.1.1970').AddSeconds($Stamp)
      )
    }
    
    function Format-Output([Object]$Type) {
      $Type.PSObject.Properties | % {'{0, 16} {1}' -f ('{0:X}' -f $_.Value), $_.Name}
    }
    
    $del = '-' * 35
    #expand file path
    $FileName = cvpa $FileName
    
    #verify that System.Deployment assembly was loaded
    $asm = 'System.Deployment'
    
    if (!([AppDomain]::CurrentDomain.GetAssemblies() | ? {
      $_.FullName -match $asm
    })) {Add-Type -Assembly $asm}
    #prepare types
    $PEStream = Get-Class $asm $($asm + '.Application.PEStream')
    $PEStream.GetNestedTypes([Reflection.BindingFlags]32) | ? {
      !$_.IsSerializable -and $_.Name -cmatch 'IMAGE'
    } | % {$NonSerial = @()}{$NonSerial += $_.Name}
    
    if ($NonSerial.Length -ne 3) {break}
    
    $IMAGE_DOS_HEADER        = Get-Struct $PEStream $NonSerial[0]
    $IMAGE_FILE_HEADER       = Get-Struct $PEStream $NonSerial[1]
    $IMAGE_OPTIONAL_HEADER32 = Get-Struct $PEStream $NonSerial[2]
    
$code = @'
using System;
using System.Reflection;
using System.Runtime.InteropServices;

[assembly: AssemblyVersion("2.0.0.0")]
[assembly: CLSCompliant(true)]
[assembly: ComVisible(false)]

namespace PEUtils {
  public sealed class Header {
    private Header() {}

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    internal struct IMAGE_OPTIONAL_HEADER64 {
      public UInt16 Magic;
      public Byte MajorLinkerVersion;
      public Byte MinorLinkerVersion;
      public UInt32 SizeOfCode;
      public UInt32 SizeOfInitializedData;
      public UInt32 SizeOfUninitializedData;
      public UInt32 AddressOfEntryPoint;
      public UInt32 BaseOfCode;
      public UInt64 ImageBase;
      public UInt32 SectionAlignment;
      public UInt32 FileAlignment;
      public UInt16 MajorOperatingSystemVersion;
      public UInt16 MinorOperatingSystemVersion;
      public UInt16 MajorImageVersion;
      public UInt16 MinorImageVersion;
      public UInt16 MajorSubsystemVersion;
      public UInt16 MinorSubsystemVersion;
      public UInt32 Win32VersionValue;
      public UInt32 SizeOfImage;
      public UInt32 SizeOfHeaders;
      public UInt32 CheckSum;
      public UInt16 Subsystem;
      public UInt16 DllCharacteristics;
      public UInt64 SizeOfStackReserve;
      public UInt64 SizeOfStackCommit;
      public UInt64 SizeOfHeapReserve;
      public UInt64 SizeOfHeapCommit;
      public UInt32 LoaderFlags;
      public UInt32 NumberOfRvaAndSizes;
    }
  }
}
'@

    Add-Type $code -WarningAction 0
    $IMAGE_OPTIONAL_HEADER64 = Get-Struct ('PEUtils.Header' -as [Type]) IMAGE_OPTIONAL_HEADER64
  }
  process {
    try {
      $fs = New-Object IO.FileStream($FileName, [IO.FileMode]::Open, [IO.FileAccess]::Read)
      $br = New-Object IO.BinaryReader($fs)
      
      $dos = Trace-Binary $br $IMAGE_DOS_HEADER
      [void]$fs.Seek($dos.e_lfanew, [IO.SeekOrigin]::Begin)
      $sig = $br.ReadUInt32()
      
      $fh = Trace-Binary $br $IMAGE_FILE_HEADER
      if ($fh.Machine -eq 0x14C) {
        $pe32 = Trace-Binary $br $IMAGE_OPTIONAL_HEADER32
      }
      elseif ($fh.machine -eq 0x8664) {
        $pe32 = Trace-Binary $br $IMAGE_OPTIONAL_HEADER64
      }
    }
    catch {$exp = [Boolean]$_.Exception}
    finally {
      if ($br -ne $null) {$br.Close()}
      if ($fs -ne $null) {$fs.Close()}
    }
  }
  end {
    switch($exp) {
      $true {Write-Host File $($FileName) is not valid PE.`n -fo Red}
      default {
        "FILE HEADER VALUES`n$del"
        Format-Output $fh
        "$del`nTime stamp $(Trace-Stamp $fh.TimeDateStamp)"
        "Machine type is $([Reflection.ImageFileMachine]$fh.Machine)`n`n"
        "OPTIONAL HEADER VALUES`n$del"
        Format-Output $pe32
        ""
      }
    }
  }
}
