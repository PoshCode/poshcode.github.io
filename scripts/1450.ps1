# Detect 32 or 64 bits Windows – regardless of WoW64 – with the PowerShell OSArchitecture function
# By Vincent Hoogendoorn
@@# See http://vincenth.net/blog/archive/2009/11/02/detect-32-or-64-bits-windows-regardless-of-wow64-with-the-powershell-osarchitecture-function.aspx for details.
@@# For the used InvokeCSharp function source, see http://vincenth.net/blog/archive/2009/10/27/call-inline-c-from-powershell-with-invokecsharp.aspx
@@# or search https://PoshCode.org for InvokeCSharp

Function global:CurrentProcessIsWOW64
{
    # Use some inline C# code to call the unmanaged IsWow64Process() function in Kernel32.dll and return its result:
    $code = @"
        using System;
        using System.Runtime.InteropServices;

        public class Kernel32
        {
            [DllImport("kernel32.dll", SetLastError = true, CallingConvention = CallingConvention.Winapi)]
            [return: MarshalAs(UnmanagedType.Bool)]
            public static extern bool IsWow64Process([In] IntPtr hProcess, [Out] out bool lpSystemInfo);

            // This overload returns True if the current process is running on Wow, False otherwise
            public bool CurrentProcessIsWow64()
            {
                bool retVal;
                if (!(IsWow64Process(System.Diagnostics.Process.GetCurrentProcess().Handle, out retVal))) { throw new Exception("IsWow64Process() failed"); }
                return retVal;
            }
        }
"@
    InvokeCSharp -code $code -class 'Kernel32' -method 'CurrentProcessIsWow64'
}

Function global:ProcessArchitecture
{
    switch ([System.IntPtr]::Size)
    {
        4 { 32 }
        8 { 64 }
        default { throw "Unknown Process Architecture: $([System.IntPtr]::Size * 8) bits" }
    }
}

Function global:OSArchitecture
{
    if (((ProcessArchitecture) -eq 32) -and (CurrentProcessIsWOW64)) { 64 } else { ProcessArchitecture }
    # Note that on Vista, W2008 and later Windows versions, we could use (Get-WMIObject win32_operatingsystem).OSArchitecture.
    # We don't use that because we also support W2003
}
