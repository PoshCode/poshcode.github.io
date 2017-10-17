<#======================================================================================
         File Name : Startup.ps1
   Original Author : Kenneth C. Mazie
                   : 
       Description : This is a personal startup script with pop-up notification and 
		   : checks to assure things are not already running.
                   : 
                   : There are 2 samples included, taskmanager and Firefox.  Add as many 
                   : as required.
                   : 
                   : To call the script use the following in a shortcut or in the RUN registry key.
				   : "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden –Noninteractive -NoLogo -Command "&{C:\Startup.ps1}"
                   : Change the script name and path as needed to suit your environment.
                   : 
                   : Be sure to enter the proper process name or errors will result.  Use
                   : "get-process" by itself to list running proces names that PowerShell 
                   : will be happy with, just make sure each app you want a name for is already
		   : running first. 
                   : 
                   : A sleep delay is added to smooth out processing but can be removed if needed.
                   : 
             Notes : Sample script is safe to run as written. 
                   : 
          Warnings : None.
                   :   
                   : 
    Last Update by : Kenneth C. Mazie (kcmjr)
   Version History : v1.0 - 05-03-12 - Original 
    Change History : v1.1 - 00-00-00 -  
                   :
=======================================================================================#>
clear-host

$Icon = [System.Drawing.SystemIcons]::Information
$Notify = new-object system.windows.forms.notifyicon
$Notify.icon = $Icon  		#--[ NOTE: Available tooltip icons are = warning, info, error, and none, specified in lines below following "tooltipicon"
$Notify.visible = $true

Function LoadApps {
if((get-process "taskmgr" -ea SilentlyContinue) -eq $Null){start-process "C:\Windows\System32\taskmgr.exe";$Notify.ShowBalloonTip(2500,"Custom Startup Script","Task Manager is loading",[system.windows.forms.tooltipicon]::Info)}else{$Notify.ShowBalloonTip(2500,"Custom Startup Script","Task Manager is already running",[system.windows.forms.tooltipicon]::Info) }
sleep (2)
if((get-process "firefox" -ea SilentlyContinue) -eq $Null){start-process "C:\Program Files (x86)\Mozilla Firefox\firefox.exe";$Notify.ShowBalloonTip(2500,"Custom Startup Script","FireFox is loading",[system.windows.forms.tooltipicon]::Info)}else{$Notify.ShowBalloonTip(2500,"Custom Startup Script","Firefox Already Running",[system.windows.forms.tooltipicon]::Info) }
sleep (2)
}

LoadApps
