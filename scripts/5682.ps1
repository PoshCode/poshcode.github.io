<#
 # Function to select any file using GUI from Powershell
 #Downloaded from technet
 http://blogs.technet.com/b/heyscriptingguy/archive/2009/09/01/hey-scripting-guy-september-1.aspx
#>

Function Get-FileName($initialDirectory)
{  
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 return($OpenFileDialog.filename)
} #end function Get-FileName

# *** Entry Point to Script ***
$inpoutfilepath =   Get-FileName -initialDirectory "c:\"
if($inpoutfilepath -ne "")
{
    if (Test-Path $inpoutfilepath)  #"D:\servers.txt"
    {
         $ComputerNames=Get-Content $inpoutfilepath
    
         foreach ($ComputerName in $ComputerNames) 
         {
            start-process cmd  " /c ping $ComputerName -t"
          }
    }
    else
    {
        Write-Warning "unable to find the input file"
    } 
}
    else
    {
        Write-Warning "No File has been selected"
    }

