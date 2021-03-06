Add-Type @'
using System;
using System.Reflection;
using System.Runtime.InteropServices;

[assembly: AssemblyVersion("1.0.0.0")]

namespace PowerStatus {
  internal static class NativeMethods {
    internal enum ACLStatus : byte {
      Offline = 0,
      Online,
      Unknown = 255
    }
    
    internal enum BttrFlags : byte {
      High            = 1,
      Low,
      Critical        = 4,
      Charging        = 8,
      NoSystemBattery = 128,
      Unknown         = 255
    }
    
    internal enum BttrLife  : byte {
      Unknown = 255
    }
    
    [StructLayout(LayoutKind.Sequential)]
    internal struct SYSTEM_POWER_STATUS {
      public ACLStatus ACLineStatus;
      public BttrFlags BatteryFlag;
      public BttrLife  BetteryLifePercent;
      public Byte      Reserved1;
      public Int32     BatteryLifeTime;
      public Int32     BatteryFullLifeTime;
    }
    
    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    internal static extern Boolean GetSystemPowerStatus(
        out SYSTEM_POWER_STATUS lpSystemPowerStatus
    );
    
    internal static void GetStatus() {
      SYSTEM_POWER_STATUS sps = new SYSTEM_POWER_STATUS();
      Boolean res = GetSystemPowerStatus(out sps);
      
      if (!res) {
        Console.WriteLine(Marshal.GetLastWin32Error());
        Environment.Exit(-1);
      }
      
      Console.WriteLine("POWER STATUS OF THE SYSTEM");
      foreach (FieldInfo fi in typeof(SYSTEM_POWER_STATUS).GetFields()) {
        if (fi.Name.Equals("BatteryLifeTime") || fi.Name.Equals("BatteryFullLifeTime")) {
          if ((Int32)fi.GetValue(sps) == -1) Console.WriteLine("{0, 19} : Unknown", fi.Name);
          else {
            TimeSpan ts = TimeSpan.FromSeconds((Int32)fi.GetValue(sps));
            Console.WriteLine("{0, 19} : {1:d2}:{2:d2}:{3:d2}", fi.Name, ts.Hours, ts.Minutes, ts.Seconds);
          }
        }
        else Console.WriteLine("{0, 19} : {1}", fi.Name, fi.GetValue(sps));
      }
    }
  }
  
  public sealed class Check {
    public static void GetStatus() {
      NativeMethods.GetStatus();
    }
  }
}
'@
[PowerStatus.Check]::GetStatus()
