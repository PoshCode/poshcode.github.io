#Hightlight the name of a file or URL and this will opened or shown in browser
if ($PSVersionTable.BuildVersion.build -le 7000)
{
    # PowerShell V2 CTP3
    function Start-Selected
    {
        $ed = $psise.CurrentOpenedFile.Editor
        start $ed.SelectedText
    }
}
else
{
    # PowerShell W7 
    function Start-Selected
    {
        $file = $psIse.CurrentPowerShellTab.Output.SelectedText
        if ($file -eq '')
        {
            $file = $psise.CurrentFile.Editor.SelectedText
        }
        if ($file)
        {
            start $file
        }    
    }
}
#Set-CustomMenu "Start Selected" {Start-Selected} 'Ctrl+Shift+S'

