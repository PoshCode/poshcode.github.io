function Reset-Tray {

   Add-Type -Assembly UIAutomationClient

   $Window = Add-Type -Name ([char[]](65..90 | Get-Random -count 10) -join "") -Member @"
   [DllImport("user32")]
   public static extern IntPtr PostMessage(IntPtr hWnd, UInt32 Msg, Int32 wParam, Int32 lParam);

   public static void SendMouseMove(IntPtr hWnd, ushort x, ushort y) {
      int point = (y << 16) + x;
      PostMessage(hWnd, 0x200, 0, point);
   } 
"@ -Passthru 


   $tray1 = [System.Windows.Automation.AutomationElement]::RootElement.FindAll( "Descendants" , [System.Windows.Automation.Condition]::TrueCondition ) | 
            Where { $_.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::ClassNameProperty) -like "SysPager" }
   # On Windows7 and Vista there's this, like, sub-tray thing
   $tray2 = $tray1.FindAll( "Children" , [System.Windows.Automation.Condition]::TrueCondition ) |
            Where { $_.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::NameProperty) -eq "User Promoted Notification Area" }
           
   $tray = $(if($tray2) { $tray2 } else { $tray1 })

   $handle = $tray.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::NativeWindowHandleProperty)
   $rect = $tray.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::BoundingRectangleProperty) 
   $y = $rect.Height/2
   for ( $x = 0; $x -lt $rect.Width; $x += 8) {
      $Window::SendMouseMove( $handle, $x, $y )
   }

}
