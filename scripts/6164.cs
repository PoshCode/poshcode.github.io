using System;
using System.Linq;
using System.Reflection;
using System.ComponentModel;
using System.Text.RegularExpressions;
using System.Runtime.InteropServices;

internal sealed class Program {
  private static RtlAdjustPrivilegeDelegate RtlAdjustPrivilege {get; set;}
  private static RtlNtStatusToDosErrorDelegate RtlNtStatusToDosError {get; set;}
  
  private const String NTDLL          = "ntdll.dll";
  private const Int32  STATUS_SUCCESS = 0;
  /// <remarks>
  /// https://msdn.microsoft.com/en-us/library/bb530716(VS.85).aspx
  /// For example, SeShutdownPrivilege = 19
  /// </remarks>
  private const UInt32 SeShutdownPrivilege = 19;
  
  /// <remarks>
  /// Wrapper for reflected GetModuleHandle and GetprocAddress.
  /// </remarks>
  private static T GetProcAddress<T>(String dll, String fun) where T : class {
    IntPtr ptr;
    
    var methods = Assembly
        .GetAssembly(typeof(Object))
        .GetType("Microsoft.Win32.Win32Native")
        .GetMethods(BindingFlags.Static | BindingFlags.NonPublic)
        .Where(m => new Regex(@"\AGet(ProcA|Mod).*").IsMatch(m.Name))
        .ToList();
    if ((ptr = (IntPtr)methods[1].Invoke(null, new Object[] {
      (IntPtr)methods[0].Invoke(null, new Object[] {dll}), fun
    })) == IntPtr.Zero) {
      throw new Win32Exception(Marshal.GetLastWin32Error());
    }
    
    return Marshal.GetDelegateForFunctionPointer(ptr, typeof(T)) as T;
  }
  
  /// <remarks>
  /// Enables or disables a privilege from the calling thread or process.
  /// http://source.winehq.org/WineAPI/RtlAdjustPrivilege.html
  /// </remarks>
  [UnmanagedFunctionPointer(CallingConvention.Winapi)]
  private delegate Int32 RtlAdjustPrivilegeDelegate(
      UInt32      Privilege,
      Boolean     Enable,
      Boolean     CurrentThread,
      ref Boolean Enabled
  );
  
  /// <remarks>
  /// Converts the specified NTSTATUS code to its equivalent system error code.
  /// https://msdn.microsoft.com/en-us/library/windows/desktop/ms680600(v=vs.85).aspx
  /// </remarks>
  [UnmanagedFunctionPointer(CallingConvention.Winapi)]
  private delegate UInt32 RtlNtStatusToDosErrorDelegate(
      Int32 Status
  );
  
  private static void LocateSignatures() {
    RtlAdjustPrivilege = GetProcAddress<RtlAdjustPrivilegeDelegate>(
        NTDLL, "RtlAdjustPrivilege"
    );
    RtlNtStatusToDosError = GetProcAddress<RtlNtStatusToDosErrorDelegate>(
        NTDLL, "RtlNtStatusToDosError"
    );
  }
  
  static void Main() {
    Boolean enabled = false;
    Int32 ntstatus;
    
    try {
      LocateSignatures();
    }
    catch (Win32Exception e) {
      Console.WriteLine(e.Message);
      return;
    }
    
    // suspend to check what privilege disabled
    Console.ReadKey();
    
    if ((ntstatus = RtlAdjustPrivilege(
        SeShutdownPrivilege, true, false, ref enabled
    )) != STATUS_SUCCESS) {
      Console.WriteLine(
        new Win32Exception((Int32)RtlNtStatusToDosError(ntstatus)).Message
      );
    }
    
    // suspend to check what privilege enabled
    Console.ReadKey();
  }
}
