## Get-XamlControlTemplate
## Dump a WPF control's default XAML template
########################################################################################################################
## Usage:
## Get-XamlControlTemplate System.Windows.Navigation.NavigationWindow
## Get-XamlControlTemplate MenuItem
## Get-XamlControlTemplate Grid
########################################################################################################################
## History:
## v 1.0 First working version
########################################################################################################################
Param ( [string]$control )

if( !$control.Contains(".") ) {
   $control = "System.Windows.Controls.$control"
}

Add-Type -AssemblyName PresentationFramework


$ctrl = new $control
$win = new Windows.Window

try {
   $win.Content = $ctrl
} catch {
   $win = new $control
}

$win.Show()

$win.Dispatcher.Invoke( "Render", [Windows.Input.InputEventHandler]{ $win.UpdateLayout() }, $null, $null)

$settings = new-object Xml.XmlWriterSettings
$settings.Indent = $true
$settings.IndentChars = " "*4
$settings.NewLineOnAttributes = $true
$builder = new Text.StringBuilder
$xmlWriter = [Xml.XmlWriter]::Create($builder, $settings)
[WIndows.Markup.XamlWriter]::Save($ctrl.Template, $xmlWriter)

$builder.ToString()

$win.Close()
