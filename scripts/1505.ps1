# see http://msdn2.microsoft.com/en-us/library/bb201634.aspx
#
# *NdisDeviceType 
#
# The type of the device. The default value is zero, which indicates a standard
# networking device that connects to a network.
#
# Set *NdisDeviceType to NDIS_DEVICE_TYPE_ENDPOINT (1) if this device is an
# endpoint device and is not a true network interface that connects to a network.
# For example, you must specify NDIS_DEVICE_TYPE_ENDPOINT for devices such as
# smart phones that use a networking infrastructure to communicate to the local
# computer system but do not provide connectivity to an external network. 
#
# Usage: run in an elevated shell (vista/longhorn) or as adminstrator (xp/2003).
#
# PS> .\fix-vmnet-adapters.ps1

# boilerplate elevation check

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = new-object Security.Principal.WindowsPrincipal $identity
$elevated = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $elevated) {
    $error = "Sorry, you need to run this script"
    if ([System.Environment]::OSVersion.Version.Major -gt 5) {
        $error += " in an elevated shell."
    } else {
        $error += " as Administrator."
    }
    throw $error
}

function confirm {
    $host.ui.PromptForChoice("Continue", "Process adapter?",
        [Management.Automation.Host.ChoiceDescription[]]@("&No", "&Yes"), 0) -eq $true
}

# adapters key
pushd 'hklm:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}'

# ignore and continue on error
dir -ea 0  | % {
    $node = $_.pspath
    $desc = gp $node -name driverdesc
    if ($desc -like "*vmware*") {
        write-host ("Found adapter: {0} " -f $desc.driverdesc)
        if (confirm) {
            new-itemproperty $node -name '*NdisDeviceType' -propertytype dword -value 1
        }
    }
}
popd

# disable/enable network adapters
gwmi win32_networkadapter | ? {$_.name -like "*vmware*" } | % {
    
    # disable
    write-host -nonew "Disabling $($_.name) ... "
    $result = $_.Disable()
    if ($result.ReturnValue -eq -0) { write-host " success." } else { write-host " failed." }
    
    # enable
    write-host -nonew "Enabling $($_.name) ... "
    $result = $_.Enable()
    if ($result.ReturnValue -eq -0) { write-host " success." } else { write-host " failed." }
}

