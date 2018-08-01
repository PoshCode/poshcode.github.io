[Reflection.Assembly]::Load("UIAutomationClient, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
[Reflection.Assembly]::Load("UIAutomationTypes, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")

function Select-Window {
PARAM( [string]$Text="*", [switch]$Recurse,
       [System.Windows.Automation.AutomationElement]$Parent = [System.Windows.Automation.AutomationElement]::RootElement ) 
PROCESS {
   if($Recurse) {
      $Parent.FindAll( "Descendants", [System.Windows.Automation.Condition]::TrueCondition ) | 
      Where-Object { $_.GetCurrentPropertyValue([System.Windows.Automation.AutomationElementIdentifiers]::NameProperty)  -like $Text } |
      Add-Member -Name Window -Type ScriptProperty -Value {$this.GetCurrentPattern( [System.Windows.Automation.WindowPattern]::Pattern )} -Passthru
   } else {
      $Parent.FindAll( "Children", [System.Windows.Automation.Condition]::TrueCondition ) | 
      Where-Object { $_.GetCurrentPropertyValue([System.Windows.Automation.AutomationElementIdentifiers]::NameProperty)  -like $Text }|
      Add-Member -Name Window -Type ScriptProperty -Value {$this.GetCurrentPattern( [System.Windows.Automation.WindowPattern]::Pattern )} -Passthru
   }
}}

### To minimize notepad, for example
# $notepad = select-window *notepad
# $notepad | ForEach { $_.Window.SetWindowVisualState("Minimized") }
