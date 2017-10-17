
# Target and remove Lenovo Software
$lenguids = get-wmiobject -class win32_product | where-object {$_.Name -like "Lenovo *"} | where-object {$_.Name -notmatch "Auto Scroll"} | where-object {$_.Name -notmatch "USB"}
foreach($guid in $hpguids){
    $id = $guid.IdentifyingNumber
     write-host ""$guid.Name" is being removed."
     &cmd /c "msiexec /uninstall $($id) /qn /norestart"
    }

# Target and remove Nitro Pro
$nitroguid = get-wmiobject -class win32_product | Where-Object {$_.Name -like "*Nitro*"}
foreach($guid in $nitroguid){
    $id = $guid.IdentifyingNumber
     write-host ""$guid.Name" is being removed."
     &cmd /c "msiexec /uninstall $($id) /qn /norestart"
    } 

# Target and remove ThinkVantage Active Protection System
$tvapsguid = get-wmiobject -class win32_product | Where-Object {$_.Name -like "*ThinkVantage*"}
foreach($guid in $tvapsguid){
    $id = $guid.IdentifyingNumber
     write-host ""$guid.Name" is being removed."
     &cmd /c "msiexec /uninstall $($id) /qn /norestart"
    } 

# Target and remove "Create Recovery Media" software
$recoveryguid = get-wmiobject -class win32_product | Where-Object {$_.Name -like "*Recovery Media*"}
foreach($guid in $recoveryguid){
    $id = $guid.IdentifyingNumber
     write-host ""$guid.Name" is being removed."
     &cmd /c "msiexec /uninstall $($id) /qn /norestart"
    } 
 
# Target and remove Lenovo Message Center Plus
$lmcpguid = get-wmiobject -class win32_product | Where-Object {$_.Name -like "*Message Center Plus*"}
foreach($guid in $lmcpguid){
    $id = $guid.IdentifyingNumber
     write-host ""$guid.Name" is being removed."
     &cmd /c "msiexec /uninstall $($id) /qn /norestart"
    } 
 
# Target and remove Multifactor Authentication Client
$mfacguid = get-wmiobject -class win32_product | Where-Object {$_.Name -like "*Multifactor Authentication Client*"}
foreach($guid in $mfacguid){
    $id = $guid.IdentifyingNumber
     write-host ""$guid.Name" is being removed."
     &cmd /c "msiexec /uninstall $($id) /qn /norestart"
    } 
 
# Target and remove Softex Inc. software
$softexguid = get-wmiobject -class win32_product | Where-Object {$_.Vendor -like "*Softex*"}
foreach($guid in $softexguid){
    $id = $guid.IdentifyingNumber
     write-host ""$guid.Name" is being removed."
     &cmd /c "msiexec /uninstall $($id) /qn /norestart"
    } 
 

 
# Target and remove Microsoft Office Trial
$officeguid = get-wmiobject -class win32_product | Where-Object {$_.Name -like "*Microsoft Office*"}
foreach($guid in $officeguid){
    $id = $guid.IdentifyingNumber
     write-host ""$guid.Name" is being removed."
     &cmd /c "msiexec /uninstall $($id) /qn /norestart"
    } 
 
 
#Remove Lenovo Communications Utility
write-host "Lenovo Communications Utility  is being removed."
&cmd /c "C:\Program Files\Lenovo\Communications Utility\unins000.exe" /SILENT /NORESTART

#Remove Lenovo RapidBoot
write-host "Lenovo RapidBoot  is being removed."
&cmd /c "C:\Program Files (x86)\Lenovo\RapidBoot HDD Accelerator\Uninstall.exe" /S

#Remove Lenovo SHAREit
write-host "Lenovo SHAREit  is being removed."
&cmd /c "C:\Program Files (x86)\Lenovo\SHAREit\unins000.exe" /SILENT


 
 
# Lenovo Patch Utility 64 bit				MsiExec.exe /X{49A09C2C-FFF4-478E-B397-5E0979F67F5D}
# Lenovo Patch Utility					MsiExec.exe /X{E8F27ADF-B1ED-41AF-A7EF-D5E71778480C}
# Norton Internet Security				"C:\Program Files (x86)\NortonInstaller\{0C55C096-0F1D-4F28-AAA2-85EF591126E7}\NIS\A5E82D02\21.3.0.12\InstStub.exe" /X /ARP

