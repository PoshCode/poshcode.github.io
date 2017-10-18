#requires -version 2.0
Add-Type @'
using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;

[assembly: AssemblyVersion("2.0.0.0")]

namespace Mime {
  internal static class NativeMethods {
    [DllImport("urlmon.dll", CharSet = CharSet.Unicode)]
    internal static extern Int32 FindMimeFromData(
        IntPtr pBC,
        String pwzUrl,
        [MarshalAs(UnmanagedType.LPArray, ArraySubType=UnmanagedType.I1, SizeParamIndex = 3)]
        Byte[] pBuffer,
        UInt32 cbSize,
        String pwzMimeProposed,
        UInt32 dwMimeFlags,
        out IntPtr ppwzMimeOut,
        Int32 dwReserved
    );
  }
  
  public sealed class Check {
    public static String GetMimeType(String file) {
      IntPtr mimeout;
      UInt32 content;
      Byte[] buf;
      String mime = null;
      
      try {
        content = (UInt32)new FileInfo(file).Length;
        if (content > 4096) content = 4096;
        
        using (FileStream fs = File.OpenRead(file)) {
          buf = new Byte[content];
          fs.Read(buf, 0, buf.Length);
        }
        
        if ((NativeMethods.FindMimeFromData(IntPtr.Zero, file, buf, content, null, 0, out mimeout, 0)) == 0) {
          mime = Marshal.PtrToStringUni(mimeout);
          Marshal.FreeCoTaskMem(mimeout);
        }
      }
      catch (IOException ie) {Console.WriteLine(ie.Message);}
            
      return mime;
    }
  }
}
'@

$args | % {[Mime.Check]::GetMimeType($_)}
