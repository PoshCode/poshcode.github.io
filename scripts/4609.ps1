# pstools.ps1

<#
function get-color {
    $cdlg = new-object system.windows.forms.colordialog
    if ($cdlg.showdialog() -eq "OK") {
        $cdlg.color
    }
    $cdlg.dispose()
}
#>

# PASTE FROM HERE DOWN INTO NUGET PACKAGE MANAGER CONSOLE
$map = @{}
$map['PowerShell Attribute'] = [System.Drawing.Color]'#FFB0C4DE'
$map['PowerShell Command'] = [System.Drawing.Color]'#FFE0FFFF'
$map['PowerShell Command Argument'] = [System.Drawing.Color]'#FFEE82EE'
$map['PowerShell Command Parameter'] = [System.Drawing.Color]'#FFFFE4B5'
$map['PowerShell Comment'] = [System.Drawing.Color]'#FF98FB98'
$map['PowerShell Keyword'] = [System.Drawing.Color]'#FFE0FFFF'
$map['PowerShell Number'] = [System.Drawing.Color]'#FFFFE4C4'
$map['PowerShell Operator'] = [System.Drawing.Color]'#FFD3D3D3'
$map['PowerShell String'] = [System.Drawing.Color]'#FFDB7093'
$map['PowerShell Type'] = [System.Drawing.Color]'#FF8FBC8F'
$map['PowerShell Variable'] = [System.Drawing.Color]'#FFFF4500'
$map['PowerShell Member'] = [System.Drawing.Color]'#FFF5F5F5'
$map['PowerShell Group End'] = [System.Drawing.Color]'#FFF5F5F5'
$map['PowerShell Group Start'] = [System.Drawing.Color]'#FFF5F5F5'

# set powershell tools token color scheme
$tokens = $dte.Properties("FontsAndColors", "TextEditor").Item("FontsAndColorsItems").object
$tokens | ? name -like "PowerShell *" | % { $_.Foreground = [system.drawing.colortranslator]::ToOle($map[$_.name]) }
