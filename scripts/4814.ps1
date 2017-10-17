$code =  @'
using System;
using System.Threading;
using System.Reflection;
using System.Runtime.InteropServices;

[assembly: AssemblyVersion("2.0.0.0")]
[assembly: CLSCompliant(true)]
[assembly: ComVisible(false)]

namespace Desktops {
  internal static class NativeMethods {
    internal enum ACCESS_MASK : uint { //UInt32
      DESKTOP_NONE            = 0,
      DESKTOP_READOBJECTS     = 0x0001,
      DESKTOP_CREATEWINDOW    = 0x0002,
      DESKTOP_CREATEMENU      = 0x0004,
      DESKTOP_HOOKCONTROL     = 0x0008,
      DESKTOP_JOURNALRECORD   = 0x0010,
      DESKTOP_JOURNALPLAYBACK = 0x0020,
      DESKTOP_ENUMERATE       = 0x0040,
      DESKTOP_WRITEOBJECTS    = 0x0080,
      DESKTOP_SWITCHDESKTOP   = 0x0100,
      
      GENERIC_ALL = (DESKTOP_CREATEMENU | DESKTOP_CREATEWINDOW | DESKTOP_ENUMERATE |
             DESKTOP_HOOKCONTROL | DESKTOP_JOURNALPLAYBACK | DESKTOP_JOURNALRECORD |
                DESKTOP_READOBJECTS | DESKTOP_SWITCHDESKTOP | DESKTOP_WRITEOBJECTS )
    }
    
    [DllImport("kernel32.dll")]
    internal static extern UInt32 GetCurrentThreadId();
    
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    internal static extern Boolean CloseDesktop(IntPtr hDesktop);
    
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    internal static extern IntPtr CreateDesktop(
      String lpszDesktop, String lpszDevice, String pDevmode,
      Int32 dwFlags, ACCESS_MASK dwDesiredAccess, IntPtr lpsa
    );
    
    [DllImport("user32.dll")]
    internal static extern IntPtr GetThreadDesktop(UInt32 dwThreadId);
    
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    internal static extern Boolean SetThreadDesktop(IntPtr hDesktop);
    
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    internal static extern Boolean SwitchDesktop(IntPtr hDesktop);
  }
  
  public sealed class VirtualDesktop {
    private VirtualDesktop() {}
    
    public static void CreateDemoDesktop(String deskName) {
      //current desktop pointer
      IntPtr oldDesk = NativeMethods.GetThreadDesktop(NativeMethods.GetCurrentThreadId());
      //new desktop
      IntPtr newDesk = NativeMethods.CreateDesktop(deskName, null, null, 0,
                       NativeMethods.ACCESS_MASK.GENERIC_ALL, IntPtr.Zero);
      NativeMethods.SetThreadDesktop(newDesk);
      NativeMethods.SwitchDesktop(newDesk);
      //timeout
      Thread.Sleep(10000);
      //delete desktop
      NativeMethods.SwitchDesktop(oldDesk);
      NativeMethods.CloseDesktop(newDesk);
    }
  }
}
'@

function frmMain_Show {
  Add-Type -Assembly System.Windows.Forms
  Add-Type $code
  [Windows.Forms.Application]::EnableVisualStyles()

  $dsk = 0
  $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
  $scr = [Windows.Forms.Screen]::PrimaryScreen.WorkingArea
  $btn = New-Object "Windows.Forms.Button[,]" 2, 2
  $pnt = New-Object Drawing.Point(($scr.Width - 395), ($scr.Height - 245))
  
  $frmMain = New-Object Windows.Forms.Form
  $mnuIcon = New-Object Windows.Forms.ContextMenuStrip
  $mnuExit = New-Object Windows.Forms.ToolStripMenuItem
  $niPopup = New-Object Windows.Forms.NotifyIcon
  #
  #common
  #
  $mnuIcon.Items.AddRange(@($mnuExit))
  #
  #mnuExit
  #
  $mnuExit.Text = "E&xit"
  $mnuExit.Add_Click({
    $niPopup.Visible = $false
    $frmMain.Close()
  })
  #
  #niPopup
  #
  $niPopup.ContextMenuStrip = $mnuIcon
  $niPopup.Icon = $ico
  $niPopup.Text = "Desktops"
  $niPopup.Visible = $true
  $niPopup.Add_Click({$frmMain.Location = $pnt})
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(390, 240)
  $frmMain.FormBorderStyle = [Windows.Forms.FormBorderStyle]::None
  $frmMain.Icon = $ico
  $frmMain.Location = $pnt
  $frmMain.ShowInTaskbar = $false
  $frmMain.StartPosition = [Windows.Forms.FormStartPosition]::Manual
  $frmMain.Text = "Desktops"
  $frmMain.TopMost = $true
  $frmMain.Add_Load({
    for ($i = 0; $i -lt 2; $i++) {
      for ($j = 0; $j -lt 2; $j++) {
        $btn[$i, $j] = New-Object Windows.Forms.Button
        $btn[$i, $j].Parent = $this
        $btn[$i, $j].Left = 6 + $j * 190
        $btn[$i, $j].Top = 10 + $i * 110
        $btn[$i, $j].Size = New-Object Drawing.Size(190, 110)
        $btn[$i, $j].Tag = $dsk++
        $btn[$i, $j].Text = $(
          if ($dsk -ne 1) {
            'Press to create Desktop' + $dsk
          }
          else {
            get $btn[$i, $j]
          }
        )
        #add desktop
        $btn[$i, $j].Add_Click({
          #hide form (do not use Hide() method because it close form)
          $frmMain.Location = New-Object Drawing.Point($scr.Width, $scr.Height)
          #remove label and create desktop
          if (![String]::IsNullOrEmpty($this.Text)) {
            [Desktops.VirtualDesktop]::CreateDemoDesktop($this.Tag.ToString())
          }
        }) #btnX_Click
      } #for
    } #for
  })
  
  #take piece of screen
  function get([Windows.Forms.Button]$ins) {
    $pic = New-Object Drawing.Bitmap(190, 110)
    $gfx = [Drawing.Graphics]::FromImage($pic)
    $gfx.CopyFromScreen([Drawing.Point]::Empty, [Drawing.Point]::Empty, $pic.Size)
    $gfx.Dispose()
    
    $bytes = (New-Object Drawing.ImageConverter).ConvertTo($pic, [Byte[]])
    $ins.Image = [Drawing.Image]::FromStream(
      (New-Object IO.MemoryStream($bytes, 0, $bytes.Length))
    )
  }
  
  [void]$frmMain.ShowDialog()
}

frmMain_Show
