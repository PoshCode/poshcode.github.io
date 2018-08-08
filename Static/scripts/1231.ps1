[Reflection.Assembly]::Load("UIAutomationClient, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
[Reflection.Assembly]::Load("UIAutomationTypes, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")

function Select-Window {
PARAM( [string]$Text="*", [switch]$Recurse,
       [System.Windows.Automation.AutomationElement]$Parent = [System.Windows.Automation.AutomationElement]::RootElement ) 
PROCESS {
   if($Recurse) {
      $Parent.FindAll( "Descendants", [System.Windows.Automation.Condition]::TrueCondition ) | 
      Where-Object { $_.GetCurrentPropertyValue([System.Windows.Automation.AutomationElementIdentifiers]::NameProperty)  -like $Text } |
      Add-Member -Name Window -Type ScriptProperty -Value {$this.GetCurrentPattern( [System.Windows.Automation.WindowPattern]::Pattern )} -Passthru |
      Add-Member -Name Transform -Type ScriptProperty -Value {$this.GetCurrentPattern( [System.Windows.Automation.TransformPattern]::Pattern )} -Passthru 
   } else {
      $Parent.FindAll( "Children", [System.Windows.Automation.Condition]::TrueCondition ) | 
      Where-Object { $_.GetCurrentPropertyValue([System.Windows.Automation.AutomationElementIdentifiers]::NameProperty)  -like $Text }|
      Add-Member -Name Window -Type ScriptProperty -Value {$this.GetCurrentPattern( [System.Windows.Automation.WindowPattern]::Pattern )} -Passthru |
      Add-Member -Name Transform -Type ScriptProperty -Value {$this.GetCurrentPattern( [System.Windows.Automation.TransformPattern]::Pattern )} -Passthru
   }
}}

### To minimize all notepad windows
# select-window *notepad | ForEach { $_.Window.SetWindowVisualState("Minimized") }

### To Close all notepad windows
# select-window *notepad | ForEach { $_.Window.Close() }

### To resize all notepad windows, be sure to make then "Normal" first (not minimized/maximized)
#  select-window *notepad | ForEach { $_.Window.SetWindowVisualState("Normal"); $_.Transform.Resize( 400, 600) }

### To tile two notepad windows
#  Add-Type -Assembly System.Windows.Forms # so we can figure out the screen size
#  $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
#
#  Select-window *notepad | Select -First 2 | Tee -Var Windows | 
#     ForEach { 
#         $_.Window.SetWindowVisualState("Normal")
#         $_.Transform.Resize( ($bounds.Width/2), $bounds.Height ) 
#     }
#  $windows[0].Transform.Move( ($bounds.Left), ($bounds.Top) )
#  $windows[1].Transform.Move( ($bounds.Left + $bounds.Width/2),($bounds.Top)  )
                            
