<# 
   Script By Matthew Painter 15-July-2013
   Copyright Sunshine Coast Council
#>




$flashview = "C:\Flash_App_SMA_Solar\Flashview.exe"
$MaxRunTimeHours = 3
$AppTitle = "Adobe Flash Player 9"




Write-Host "FlashView Monitor`n`nThis script will relaunch Flashview if it crashes, make it full screen again if it drops out, and restart application every $MaxRunTimeHours hours`n`nClose this window to stop monitoring Flashview Application"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class SMA {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
}
"@



Invoke-Item $flashview
Start-Sleep -Seconds 2

$start = get-date

do{

    try
    {
        $FlashViewProcess = get-process -Name "flashview" -ErrorAction 'stop'
    }
    catch
    {
        $FlashViewProcess = $null
    } 

    if ($FlashViewProcess)
    {
        [Microsoft.VisualBasic.Interaction]::AppActivate($AppTitle)
        Start-Sleep -Seconds 2
        $a = [SMA]::GetForegroundWindow()
        $currentActiveWindow = get-process | ? { $_.mainwindowhandle -eq $a } | select -ExpandProperty MainWindowTitle
        
        if ($AppTitle -eq $currentActiveWindow)
        {    
            [System.Windows.Forms.SendKeys]::SendWait("%V")
            [System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
            [System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
            [System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
            [System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
            [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

            $AppProblem = $false        
        } 
        else
        {
            $AppProblem = $true
        }
    } 
     

   

    $RunTime = (New-TimeSpan $Start (Get-Date)).TotalHours
    
    if (!$FlashViewProcess -or $AppProblem -or $RunTime -gt $MaxRunTimeHours)
    {    
        
        # Quiting app with escape button is graceful, history graph is preserved. 
        [System.Windows.Forms.SendKeys]::SendWait("{esc}")         
        Start-Sleep -Seconds 2
        
        try
        {
            $FlashViewProcess = get-process -Name "flashview" -ErrorAction 'stop'
        }
        catch
        {
            $FlashViewProcess = $null
        }       
        
        If ($FlashViewProcess){$FlashViewProcess | Stop-Process} 
        
        Invoke-Item $flashview 
        
        $start = Get-Date   
    }
    
    Start-Sleep -Seconds 30
    
    

}while($true)













