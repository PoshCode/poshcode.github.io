<#Examples

.Get-Hotfix | clip.exe | AutoWord

.Get-Hotfix | Format-List | clip.exe | AutoWord

#>


Function Paste {

Add-Type -AssemblyName System.Windows.Forms
$P = New-Object System.Windows.Forms.TextBox
$P.Multiline = $true
$P.Paste()
$P.Text

}

Function AutoWord {

param ([string[]]$Paste)

$Word = New-Object -ComObject Word.Application
$Word.visible = $true

if (($WordVersion -eq "12.0") -or ($WordVersion -eq "11.0"))
    {    
    $Word.DisplayAlerts = $false
    }
    else
    {
    $Word.DisplayAlerts = "wdAlertsNone"
    }

$Paste = Paste
$Document = $Word.Documents.Add()
$Selection = $Word.Selection
$Selection.TypeText("$Paste")


}

