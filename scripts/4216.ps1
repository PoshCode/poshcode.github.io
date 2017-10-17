function Invoke-BlueScreen
{
    Add-Type "
      using System;
      using System.Runtime.InteropServices;
      public class PInvoke
      {
          [DllImport(`"user32.dll`")]
          public static extern IntPtr CreateDesktop(string desktopName, IntPtr device, IntPtr deviceMode, int flags, long accessMask, IntPtr attributes);
      }
    "

    [PInvoke]::CreateDesktop("BSOD", [IntPtr]::Zero, [IntPtr]::Zero, 0, $null, [IntPtr]::Zero)
}
