$path = "$env:programfiles\Reference Assemblies\Microsoft\Framework\v3.0"
$TypesAssembly = [Reflection.Assembly]::LoadFile("$path\UIAutomationTypes.dll")
$ClientAssembly = [Reflection.Assembly]::LoadFile("$path\UIAutomationClient.dll")

$NS = "System.Windows.Automation"

[System.Diagnostics.Process]::Start(¡±notepad¡±)

$UiaElement = [System.Windows.Automation.AutomationElement]
$Desktop = $UiaElement::RootElement

$Condition = New-Object "$NS.PropertyCondition"($UiaElement::NameProperty, "Untitled - Notepad")
$Window = $Desktop.FindFirst("Children", $Condition)

$Condition = New-Object "$NS.PropertyCondition"($UiaElement::ClassNameProperty, "")
$notCondition = New-Object "$NS.NotCondition"($Condition)

@@$Control = $Window.FindFirst("Descendants", $Condition)  # $Control will be null
@@$Control.getruntimeid() # this call will fail

@@$Control = $Window.FindFirst("Descendants", $NotCondition)  # the first UI Element whose classname is not "" will be found
@@$Control.getruntimeid() # this call will succeed


