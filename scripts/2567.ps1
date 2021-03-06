#==================================================================================================
#              File Name : WSUS-Settings.ps1
#        Original Author : Kenneth C. Mazie (kcmjr at kcmjr.com)
#            Description : As written will manually apply all settings associated with a local
#                        :  WSUS server.  Ideal for use when you need to force a non-domain system
#                        :  to point to a domain based WSUS server.
#
#                  Notes : Normal operation is with no command line options. This PowerShell script
#                        :  was the result of an export of a system registry after being joined to 
#                        :  a domain and receiveing all WSUS settings from the domain policy.  
#                        :  Settings "should" mimic those found in the domain policy at:
#                        :  "Computer Configuration\Policies\Administrative Templates\Windows Components\Windows Update"
#                        :  On any domain member systems.  If the required parent keys do not exist
#                        :  it will create them.
#                        :
#                        :  The script will set ONE target group and ONE computer at a time.  It
#                        :  is intended to run locally either manually or as a startup script. 
#                        :  Primary settings are set as variables, the rest are set in the script body.
#                        :
#               Warnings : None
#                        :
#	               Legal : Public Domain.  Modify and redistribute freely.  No rights reserved.
#              	         : SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
#                        : USE AT YOUR OWN RISK. NO TECHNICAL SUPPORT PROVIDED.
#                        : 
#                Credits : None
#                        : 
#         Last Update by : Kenneth C. Mazie 
#        Version History : v1.0 - 02-19-09 - Original 
#         Change History : v1.1 - 
#
#==================================================================================================

Clear-Host

#--[ Windows Update Server Info ]--
$TargetGroup = "Computers"
$WUServer = "http://192.168.1.10"
$WUStatusServer = "http://192.168.1.10"
#-[ NOTE: all other settings should be set below ]--

#--[ Setup Windows Updates ]--
Write-Host -backgroundColor white -foregroundcolor blue -object "Setting WSUS Parameters..."

if(!( Test-Path 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' ))
{
      New-Item 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' -force
}
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' -name 'ElevateNonAdmins' -value '1' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' -name 'AcceptTrustedPublisherCerts' -value '1' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' -name 'TargetGroupEnabled' -value '1' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' -name 'TargetGroup' -value $TargetGroup -propertyType "String" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' -name 'WUServer' -value $WUServer -propertyType "String" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' -name 'WUStatusServer' -value $WUStatusServer -propertyType "String" -force

if(!( Test-Path 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' ))
{
      New-Item 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -force
}
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'NoAutoRebootWithLoggedOnUsers' -value '1' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'NoAUShutdownOption' -value '0' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'NoAUAsDefaultShutdownOption' -value '0' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'DetectionFrequencyEnabled' -value '1' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'DetectionFrequency' -value '22' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'AutoInstallMinorUpdates' -value '1' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'RebootWarningTimeoutEnabled' -value '1' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'RebootWarningTimeout' -value '5' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'RebootRelaunchTimeoutEnabled' -value '1' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'RebootRelaunchTimeout' -value '30' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'IncludeRecommendedUpdates' -value '22' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'AUPowerManagement' -value '0' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'NoAutoUpdate' -value '0' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'AUOptions' -value '4' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'ScheduledInstallDay' -value '4' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'ScheduledInstallTime' -value '3' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'UseWUServer' -value '1' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'RescheduleWaitTimeEnabled' -value '1' -propertyType "DWord" -force
New-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -name 'RescheduleWaitTime' -value '1' -propertyType "DWord" -force

Write-Host -backgroundColor white -foregroundcolor blue -object "Completed..."

