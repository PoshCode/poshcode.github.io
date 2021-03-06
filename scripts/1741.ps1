#Requires -version 2.0
## Stupid PowerShell Tricks
###################################################################################################
add-type @"
using System;
using System.Runtime.InteropServices;
public class Tricks {
   [DllImport("user32.dll")]
   private static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
   
   [DllImport("user32.dll", SetLastError = true)]
   private static extern UInt32 GetWindowLong(IntPtr hWnd, int nIndex);

   [DllImport("user32.dll")]
   static extern int SetWindowLong(IntPtr hWnd, int nIndex, IntPtr dwNewLong);

   [DllImport("user32.dll")]
   static extern bool SetLayeredWindowAttributes(IntPtr hwnd, uint crKey, byte bAlpha, uint dwFlags);

   [DllImport("user32.dll")]
   [return: MarshalAs(UnmanagedType.Bool)]
   static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, SWP uFlags);   
   
   [DllImport("dwmapi.dll", PreserveSig = false)]
   public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int attrValue, int attrSize);

   const int GWL_EXSTYLE = -20;
   const int WS_EX_LAYERED = 0x80000;
   const int WS_EX_TRANSPARENT = 0x20;
   const int LWA_ALPHA = 0x2;
   const int LWA_COLORKEY = 0x1;
   
   static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
   static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
   static readonly IntPtr HWND_TOP = new IntPtr(0);
   static readonly IntPtr HWND_BOTTOM = new IntPtr(1);
   
   [Flags]
   enum SWP : uint {
      NOSIZE = 0x0001,
      NOMOVE = 0x0002,
      NOZORDER = 0x0004,
      NOREDRAW = 0x0008,
      NOACTIVATE = 0x0010,
      FRAMECHANGED = 0x0020,  /* The frame changed: send WM_NCCALCSIZE */
      SHOWWINDOW = 0x0040,
      HIDEWINDOW = 0x0080,
      NOCOPYBITS = 0x0100,
      NOOWNERZORDER = 0x0200,  /* Don't do owner Z ordering */
      NOSENDCHANGING = 0x0400,  /* Don't send WM_WINDOWPOSCHANGING */
   }
   [Flags]
   public enum DwmWindowAttribute
   {
      NCRenderingEnabled = 1,
      NCRenderingPolicy,
      TransitionsForceDisabled,
      AllowNCPaint,
      CaptionButtonBounds,
      NonClientRtlLayout,
      ForceIconicRepresentation,
      Flip3DPolicy,
      ExtendedFrameBounds,
      HasIconicBitmap,
      DisallowPeek,
      ExcludedFromPeek,
      Last
   }

   [Flags]
   public enum DwmNCRenderingPolicy
   {
      UseWindowStyle,
      Disabled,
      Enabled,
      Last
   }

	public static void ShowWindow(IntPtr hWnd) { ShowWindowAsync(hWnd,5); }
	public static void HideWindow(IntPtr hWnd) { ShowWindowAsync(hWnd,0); }
   public static void GhostWindow(IntPtr hWnd, int percent) {
      SetWindowLong(hWnd, GWL_EXSTYLE, (IntPtr)(GetWindowLong(hWnd, GWL_EXSTYLE) | WS_EX_LAYERED | WS_EX_TRANSPARENT));
      // set transparency to X% (of 255)
      if(percent > 100) { percent = 100; }
      byte alpha = (byte)(255 * (percent/100.0));
      SetLayeredWindowAttributes(hWnd, 0, alpha, LWA_ALPHA);
      SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP.NOSIZE | SWP.NOMOVE);
   }
   public static void UnGhostWindow(IntPtr hWnd) {
      SetWindowLong(hWnd, GWL_EXSTYLE, (IntPtr)(GetWindowLong(hWnd, GWL_EXSTYLE) &~WS_EX_LAYERED &~WS_EX_TRANSPARENT));
      SetWindowPos(hWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP.NOSIZE | SWP.NOMOVE);
   }
   
   public static void RemoveFromAeroPeek(IntPtr Hwnd) //Hwnd is the handle to your window
   {
      int renderPolicy = (int)DwmNCRenderingPolicy.Enabled;
      DwmSetWindowAttribute(Hwnd, (int)DwmWindowAttribute.ExcludedFromPeek, ref renderPolicy, sizeof(int));
   }
   public static void RestoreToAeroPeek(IntPtr Hwnd) //Hwnd is the handle to your window
   {
      int renderPolicy = (int)DwmNCRenderingPolicy.Disabled;
      DwmSetWindowAttribute(Hwnd, (int)DwmWindowAttribute.ExcludedFromPeek, ref renderPolicy, sizeof(int));
   }
}
"@

$dictionary = [System.Collections.Generic.Dictionary``2]
$list = [System.Collections.Generic.List``1]
$string = [String]
$intPtr = [IntPtr]

$intPtrList = $list.AssemblyQualifiedName -replace "1,","1[[$($intPtr.AssemblyQualifiedName)]],"
$windows = new-object ($dictionary.AssemblyQualifiedName -replace "2,","2[[$($string.AssemblyQualifiedName)],[$intPtrList]],")



function Remove-GhostWindow {
<#
.SYNOPSIS
   Un-ghost a window
.PARAMETER Handle
   The window handle to a specific window we want to hide.
.PARAMETER Name
   The name of a running process whos windows you want to hide.
.EXAMPLE
   Get-Process PowerShell | Hide-Window; Sleep 5; Show-Window
   
   Hides the PowerShell window(s) for 5 seconds
#>
[CmdletBinding()]
PARAM (
   [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
   [Alias("MainWindowHandle","Handle")]
   [IntPtr]$WindowHandle=[IntPtr]::Zero
,
   [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
   [Alias("ProcessName")]
   [String]$Name
)
PROCESS { 
	(Resolve-Window $WindowHandle $Name) | ForEach-Object { [Tricks]::UnGhostWindow( $_ ) }
}
}


function Set-GhostWindow {
<#
.SYNOPSIS
   Make a window partially transparent and click-through
.PARAMETER Handle
   The window handle to a specific window we want to hide.
.PARAMETER Name
   The name of a running process whos windows you want to hide.
.PARAMETER Percent
   The percentage (from 0 to 100) of opacity you want to use (defaults to 80)
.EXAMPLE
   Get-Process PowerShell | Hide-Window; Sleep 5; Show-Window
   
   Hides the PowerShell window(s) for 5 seconds
#>
[CmdletBinding()]
PARAM (
   [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
   [Alias("MainWindowHandle","Handle")]
   [IntPtr]$WindowHandle=[IntPtr]::Zero
,
   [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
   [Alias("ProcessName")]
   [String]$Name
,
   [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
   [ValidateRange(0,100)]
   [int]$Percent = 80
)
PROCESS { 
	(Resolve-Window $WindowHandle $Name) | ForEach-Object { [Tricks]::GhostWindow( $_, $Percent ) }
}
}

function Hide-Window {
<#
.SYNOPSIS
   Hide a window
.DESCRIPTION
   Hide a window by handle or by process name. Hidden windows are gone: they don't show up in alt+tab, or on the taskbar, and they're invisible. The only way to get them back is with ShowWindow.
   Windows hidden by Hide-Window are pushed onto a stack so they can be retrieved by Show-Window. Since they're invisible, they're very hard to find otherwise.
.NOTES
   See also Show-Window
.PARAMETER WindowHandle
   The window handle to a specific window we want to hide.
.PARAMETER Name
   The name of a running process whos windows you want to hide.
.EXAMPLE
   Get-Process PowerShell | Hide-Window; Sleep 5; Show-Window
   
   Hides the PowerShell window(s) for 5 seconds
#>
[CmdletBinding()]
PARAM (
   [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
   [Alias("MainWindowHandle","Handle")]
   [IntPtr]$WindowHandle=[IntPtr]::Zero
,
   [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
   [Alias("ProcessName")]
   [String]$Name
)
PROCESS { 
	(Push-Window $WindowHandle $Name) | ForEach-Object { [Tricks]::HideWindow( $_ ) }
}
}

function Show-Window {
<#
.SYNOPSIS
   Show a window
.DESCRIPTION
   Show a window by handle or by process name. If you call it without any parameters, will show all hidden windows.
.NOTES
   See also Hide-Window
.PARAMETER WindowHandle
   The window handle to a specific window we want to show.
.PARAMETER Name
   The name of a running process whos windows you want to show.
.EXAMPLE
   Get-Process PowerShell | Hide-Window; Sleep 5; Show-Window
   
   Hides the PowerShell window(s) for 5 seconds
#>
[CmdletBinding()]

PARAM (
[Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
[Alias("MainWindowHandle","Handle")]
[IntPtr]$WindowHandle=[IntPtr]::Zero
,
[Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
[Alias("ProcessName")]
[String]$Name
)
PROCESS { 
	(Pop-Window $WindowHandle $Name) | ForEach-Object { [Tricks]::ShowWindow( $_ ) }
}
}


## PRIVATE
FUNCTION Push-Window {
   [CmdletBinding()]
	PARAM ([IntPtr]$Handle,[String]$ProcessName)
	if(!$ProcessName) { $ProcessName = "--Unknown--" }

   $Handles = Resolve-Window $Handle $ProcessName

	$windows[$ProcessName].AddRange($Handles)
	write-output $Handles
}

FUNCTION Resolve-Window  {
   [CmdletBinding()]
	PARAM ([IntPtr]$Handle,[String]$ProcessName)
	if(!$ProcessName) { $ProcessName = "--Unknown--" }
	[IntPtr[]]$Handles = @($Handle)
   
	if(!$Windows.ContainsKey($ProcessName)) {
		$windows.Add($ProcessName, (New-Object $intPtrList))
	} 
	if($Handle -eq [IntPtr]::Zero) {
		[IntPtr[]]$Handles = @(Get-Process $ProcessName | % { $_.MainWindowHandle } )
	}
   return $Handles
}

## PRIVATE
FUNCTION Pop-Window {
   [CmdletBinding()]
	PARAM ([IntPtr]$Handle,[String]$ProcessName)
	
	[IntPtr[]]$Handles = @($Handle)
	if(!$ProcessName) { $ProcessName = "--Unknown--" }
   
	if(($Handle -eq [IntPtr]::Zero) -and $windows[$ProcessName] ) {
		write-output $windows[$ProcessName]
		$Null = $windows[$ProcessName].Clear()
	} elseif($Handle -ne [IntPtr]::Zero){
		$Null = $windows[$ProcessName].Remove( $Handle )
	}

	write-output $Handles
}

Add-Type -Assembly System.Windows.Forms
function Wiggle-Mouse {
<#
.SYNOPSIS
   Wiggle the mouse until you Ctrl+Break to stop the script.
.DESCRIPTION
   Wiggle-Mouse randomly moves the mouse by a few pixels every few milliseconds until you stop the script.
.PARAMETER Variation
   The maximum distance to move the mosue in any direction.  Values that are too small aren't noticeable, and values that are too big make the user "loose" the mouse and they have no idea what happened.
.PARAMETER Name
   The name of a running process whos windows you want to hide.
.EXAMPLE
   Get-Process PowerShell | Hide-Window; Wiggle-Mouse -Duration 5;  Get-Process PowerShell | Show-Window
   
   Hides the PowerShell window and wiggle the mouse for five seconds ... :D
#>
[CmdletBinding()]
PARAM (
[Parameter(Position=0)][Int]$Variation=80,
[Parameter(Position=1)][Int]$Sleep=400,
[Parameter(Position=2)][Int]$Duration=0
)
   if(!$Duration) { Write-Host "Ctrl+C to stop wiggling :)" }
	$screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
	$random = new-object Random
   $Duration *= -1000
	While($Duration -le 0) {
		[Windows.Forms.Cursor]::Position ="$(
			$random.Next(	[Math]::Max( $screen.Left, ([System.Windows.Forms.Cursor]::Position.X - $Variation) ), 
								[Math]::Min( $screen.Right, ([System.Windows.Forms.Cursor]::Position.X + $Variation) )	)
							),$(
			$random.Next(	[Math]::Max( $screen.Top, ([System.Windows.Forms.Cursor]::Position.Y - $Variation) ), 
								[Math]::Min( $screen.Bottom, ([System.Windows.Forms.Cursor]::Position.Y + $Variation) )	)
							)" 
		sleep -milli $Sleep
      $Duration += $Sleep
	} 
}

[Reflection.Assembly]::Load("UIAutomationClient, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
function global:Select-Window {
PARAM( [string]$Title="*", 
       [string]$Process="*", 
       [switch]$Recurse,
       [System.Windows.Automation.AutomationElement]$Parent = [System.Windows.Automation.AutomationElement]::RootElement ) 
PROCESS {
   $search = "Children"
   if($Recurse) { $search = "Descendants" }
   
   $Parent.FindAll( $search, [System.Windows.Automation.Condition]::TrueCondition ) | 
   Add-Member -Type ScriptProperty -Name Title     -Value {
               $this.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::NameProperty)} -Passthru |
   Add-Member -Type ScriptProperty -Name Handle    -Value {
               $this.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::NativeWindowHandleProperty)} -Passthru |
   Add-Member -Type ScriptProperty -Name ProcessId -Value {
               $this.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::ProcessIdProperty)} -Passthru |

   Where-Object {
      ((Get-Process -Id $_.ProcessId).ProcessName -like $Process) -and ($_.Title -like $Title)
   }
}}


function Remove-AeroPeek {
PARAM(
   [string]$Title="*", 
   [string]$Process="*"
)
PROCESS {
   Foreach($window in Select-Window -Process $Process -Title $Title) { 
      [Tricks]::RemoveFromAeroPeek( $window.Handle ) 
   }
}
}
function Restore-AeroPeek {
PARAM(
   [string]$Title="*", 
   [string]$Process="*"
)
PROCESS {
   Foreach($window in Select-Window -Process $Process -Title $Title) { 
      [Tricks]::RestoreToAeroPeek( $window.Handle ) 
   }
}
}
# Remove-AeroPeek "Miranda IM"
# Remove-AeroPeek -Process Rainlendar2

Export-ModuleMember Select-Window, Show-Window, Hide-Window, Wiggle-Mouse, Set-GhostWindow, Remove-GhostWindow, Remove-AeroPeek
