$Wasp = Add-Type -MemberDefinition @'
[DllImport("user32.dll")]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool SetForegroundWindow(IntPtr hWnd);
'@ -Passthru

$null = Add-Type -Assembly System.Windows.Forms

filter Stop-Pipeline(  [scriptblock]$condition = {$true} ) {
   if (& $condition) {
      ## You need to make sure PowerShell is the foreground Window before you send Ctrl+C
      if($Wasp::SetForegroundWindow( (Get-Process -id $PID).MainWindowHandle )) {
         [System.Windows.Forms.SendKeys]::SendWait("^C")
      } else {
         Throw (New-Object System.Management.Automation.PipelineStoppedException)
      }
      $condition = { $true }  ## Make sure that once it's true, it's always true
   } else { ## Sometimes, the commands upstream manage to send out extras
      $_
   }
}

