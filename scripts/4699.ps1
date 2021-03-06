#first way
[xml]$res = @'
<?xml version="1.0"?>
<Drives>
  <Type en="CD Drive" ru="CD-&#1076;&#1080;&#1089;&#1082;&#1086;&#1074;&#1086;&#1076;" />
  <Verb en="E&amp;ject" ru="&amp;&#1048;&#1079;&#1074;&#1083;&#1077;&#1095;&#1100;" />
</Drives>
'@

$iso = (Get-Culture).TwoLetterISOLanguageName

(New-Object -com Shell.Application).NameSpace(0x11).Items() | ? {
  $_.Type -eq $res.Drives.Type.$iso
} | % {$_.InvokeVerb($res.Drives.Verb.$iso)}

#second way
$col = (New-Object -com WMPlayer.OCX).cdromCollection
for ($i = 0; $i -lt @($col).Length; $i++) {$col.Item($i).eject()}

#third way
$code = @'
[DllImport("winmm.dll")]
public static extern int mciSendString(
  String lpszCommand,
  String lpszReturnString,
  UInt32 cchReturn,
  IntPtr hwndCallback
);
'@

$asm = Add-Type -mem $code -name EjectClose -names CDRom -pass
[void]$asm::mciSendString("set cdaudio door open", $null, 0, [IntPtr]::Zero)
sleep -m 1500
[void]$asm::mciSendString("sed cdaudio door closed", $null, 0, [IntPtr]::Zero)

#fourth way
$code = @'
using System;
using System.Reflection;
using System.Globalization;
using System.Runtime.InteropServices;

[assembly: AssemblyVersion("2.0.0.0")]
[assembly: CLSCompliant(true)]
[assembly: ComVisible(false)]

namespace CDRom {
  internal static class NativeMethods {
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
    internal static extern IntPtr CreateFile(String lpFileName, UInt32 dwDesiredAccess,
        UInt32 dwSharedMode, IntPtr lpSecurityAttributes, UInt32 dwCreationDisposition,
                                    UInt32 dwFlagsAndAttributes, IntPtr hTemplateFile);

    [DllImport("kernel32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    internal static extern bool CloseHandle(IntPtr hObject);
    
    [DllImport("kernel32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    internal static extern bool DeviceIoControl(IntPtr hDevice, UInt32 dwIoControlCode,
                           IntPtr lpInBuffer, UInt32 nInBufferSize, IntPtr lpOutBuffer,
               UInt32 nOutBufferSize, out UInt32 lpBytesReturned, IntPtr lpOverlapped);
  }
  
  public sealed class Holder {
    private Holder() {}
    
    const UInt32 GENERIC_READ              = 0x80000000;
    const UInt32 IOCTL_STORAGE_EJECT_MEDIA = 0x002D4808;
    const UInt32 IOCTL_STORAGE_LOAD_MEDIA  = 0x002D480C;
    const UInt32 OPEN_EXISTING             = 3;
    const  Int32 InvalidHandle             = -1;
    
    static IntPtr hndl;
    static UInt32 retBytes;
    
    public static void OpenClose(String drvLetter, bool curStatus) {
      try {
        hndl = NativeMethods.CreateFile(drvLetter, GENERIC_READ, 0, IntPtr.Zero,
                                                        OPEN_EXISTING, 0, IntPtr.Zero);
        
        if ((Int32)hndl != InvalidHandle) {
          if (curStatus)
            NativeMethods.DeviceIoControl(hndl, IOCTL_STORAGE_EJECT_MEDIA, IntPtr.Zero,
                                         0, IntPtr.Zero, 0, out retBytes, IntPtr.Zero);
          else
            NativeMethods.DeviceIoControl(hndl, IOCTL_STORAGE_LOAD_MEDIA, IntPtr.Zero,
                                         0, IntPtr.Zero, 0, out retBytes, IntPtr.Zero);
        }
      }
      finally {
        NativeMethods.CloseHandle(hndl);
      }
    }
  }
}
'@

Add-Type $code
[IO.DriveInfo]::GetDrives() | ? {$_.DriveType -eq 'CDRom'} | % {$arr = @()}{
   $arr += ('\\.\\' + ($_.Name[0..1] -join ''))
}
$arr | % {[CDRom.Holder]::OpenClose($_, $true)}
sleep -m 1500
$arr | % {[CDRom.Holder]::OpenClose($_, $false)}
