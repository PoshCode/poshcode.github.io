using System;
using System.Reflection;
using System.Globalization;
using System.Runtime.InteropServices;

[assembly: AssemblyVersion("2.0.0.0")]

namespace CDRomOpenClose {
  internal static class WinAPI {
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
    internal static extern IntPtr CreateFile(string lpFileName, uint dwDesiredAccess,
          uint dwSharedMode, IntPtr lpSecurityAttributes, uint dwCreationDisposition,
                                    uint dwFlagsAndAttributes, IntPtr hTemplateFile);

    [DllImport("kernel32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    internal static extern bool CloseHandle(IntPtr hObject);

    [DllImport("kernel32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    internal static extern bool DeviceIoControl(IntPtr hDevice, uint dwIoControlCode,
      IntPtr lpInBuffer, uint nInBufferSize, IntPtr lpOutBuffer, uint nOutBufferSize,
                                      out uint lpBytesReturned, IntPtr lpOverlapped);
  }

  internal sealed class Program {
    const uint GENERIC_READ              = 0x80000000;
    const uint IOCTL_STORAGE_EJECT_MEDIA = 0x002D4808;
    const uint IOCTL_STORAGE_LOAD_MEDIA  = 0x002D480C;
    const uint OPEN_EXISTING             = 3;
    const  int INVALID_HANDLE            = -1;

    static IntPtr hndl;
    static   uint retBytes;

    static void EjectClose(string drvLetter, bool curStatus) {
      try {
        hndl = WinAPI.CreateFile(drvLetter, GENERIC_READ, 0,
                       IntPtr.Zero, OPEN_EXISTING, 0, IntPtr.Zero);

        if ((int)hndl != INVALID_HANDLE) {
          if (curStatus)
            WinAPI.DeviceIoControl(hndl, IOCTL_STORAGE_EJECT_MEDIA, IntPtr.Zero,
                                  0, IntPtr.Zero, 0, out retBytes, IntPtr.Zero);
          else
            WinAPI.DeviceIoControl(hndl, IOCTL_STORAGE_LOAD_MEDIA, IntPtr.Zero,
                                 0, IntPtr.Zero, 0, out retBytes, IntPtr.Zero);
        }
      }
      finally {
        WinAPI.CloseHandle(hndl);
        hndl = IntPtr.Zero;
      }
    }

    static void Main(string[] args) {
      if (args.Length == 1) {
        string arg = args[0].ToLower(CultureInfo.CurrentCulture).TrimStart('-', '/');

        switch (arg) {
          case "c": EjectClose(@"\\.\E:", false); break;
          case "e": EjectClose(@"\\.\E:", true); break;
          default: Console.WriteLine("Unknown {0} parameter.", arg); break;
        }
      }
      else
        Console.WriteLine("Arguments are out of length.");
    }
  }
}
