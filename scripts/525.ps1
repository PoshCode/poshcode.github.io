# AutoMount.psm1 v1.0   
# Oisin "x0n" Grehan (MVP)   
  
$query = new-object System.Management.WqlEventQuery   
$query.EventClassName = "__InstanceOperationEvent"  
  
# default to every 2 seconds   
$query.WithinInterval = new-object System.TimeSpan 0,0,2   
  
@@# this WMI is only available with Windows 2003 and Vista (not XP it appears).
# this could be rewritten to use different WMI queries to support 2000/NT/XP also.   
$query.QueryString = "Select * from Win32_VolumeChangeEvent"  
  
# attach a watcher   
$watcher = new-object System.Management.ManagementEventWatcher $query  
  
# here we use -SupportEvent instead of -SourceIdentifier   
# this prevents this event from being generally visible   
# also note the use of the call operator to invoke a    
# function in the scope of the module since this action   
# occurs outside of module scope.   
Register-ObjectEvent $watcher -EventName "EventArrived" `   
    -SupportEvent "WMI.VolumeChange" -Action {   
        & (get-module automount) VolumeChangeCallback @args  
    }   
  
# New PSEvents:   
#   
#     PowerShell.DeviceConfigurationChanged   
#     PowerShell.DeviceArrived   
#     PowerShell.DeviceRemoved   
#     PowerShell.DeviceDocking   
  
# win32_volumechangeevent event types   
$eventTypes = @{   
    1 = "ConfigurationChanged";   
    2 = "Arrived";   
    3 = "Removed";   
    4 = "Docking";   
}   
  
# private module level callback function   
function VolumeChangeCallback ($sender, $eventargs) {   
    trap { write-warning $_ }   
  
    $driveName = $eventArgs.NewEvent.DriveName.TrimEnd(":")   
    $eventType = [int]$eventArgs.NewEvent.EventType # was uint16   
  
    $forwardedEvent = "Device$($eventTypes[$eventType])"  
       
    # forward a new simpler event specific to device event type   
    [void]( New-PSEvent "PowerShell.$forwardedEvent" -Sender $driveName `   
        -EventArguments $eventargs )   
}   
  
# hook up our psdrive mount / unmount events   
# and start the WMI watcher   
function Enable-AutoMount {   
  
    Register-PSEvent -SourceIdentifier "PowerShell.DeviceArrived" `   
        -Action {               
            new-psdrive -name $args[0] -psprovider `   
                filesystem -root "$args[0]:";   
         }   
  
    Register-PSEvent -SourceIdentifier "PowerShell.DeviceRemoved" `   
        -Action {   
            remove-psdrive -name $args[0] -ea 0; # may not exist   
        }   
       
    $watcher.Start()   
}   
  
# tear down our psdrive mount / unmount events   
# and stop the WMI watcher   
function Disable-AutoMount {   
  
    Unregister-PSEvent -SourceIdentifier "PowerShell.DeviceArrived"  
    Unregister-PSEvent -SourceIdentifier "PowerShell.DeviceRemoved"  
       
    $watcher.Stop()   
}   
  
# export functions to control automount   
Export-ModuleMember Enable-AutoMount, Disable-AutoMount   
  
# start watching and (un)mounting   
Enable-AutoMount

