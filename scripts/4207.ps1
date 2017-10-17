$code = @'
using System;
using System.Runtime.InteropServices;

public class WinAPI {
  [DllImport("kernel32.dll")]
  internal static extern IntPtr GetConsoleWindow();

  [DllImport("user32.dll")]
  [return: MarshalAs(UnmanagedType.Bool)]
  internal static extern bool MoveWindow(IntPtr hWnd, int X,
                             int Y, int nWidth, int nHeight,
              [MarshalAs(UnmanagedType.Bool)]bool bRepaint);

  public static void ChangeConsole(int X, int Y) {
    IntPtr hwnd = GetConsoleWindow();
    //host resolution by default equals 600x300
    MoveWindow(hwnd, X, Y, 600, 300, true);
  }
}
'@

Add-Type $code
#moving host at new point
[WinAPI]::ChangeConsole(230, 130)
