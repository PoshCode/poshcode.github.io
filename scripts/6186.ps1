
<#
Requisite updates for IE11 installation on Microsoft Windows 7 x86 and x64 (Please see http://support.microsoft.com/kb/2847882)

    1. KB2729094 (http://support.microsoft.com/kb/2729094)
    2. KB2731771 (http://support.microsoft.com/kb/2731771)
    3. KB2533623 (http://support.microsoft.com/kb/2533623)
    4. KB2670838 (http://support.microsoft.com/kb/2670838)
    5. KB2786081 (http://support.microsoft.com/kb/2786081)
    6. KB2834140 (http://support.microsoft.com/kb/2834140)

Optional updates for IE11 installation on Microsoft Windows 7 x86 and x64

    1. KB2639308 (http://support.microsoft.com/kb/2639308)
    2. KB2888049 (http://support.microsoft.com/kb/2888049)
    3. KB2882822 (http://support.microsoft.com/kb/2882822)
#>

# Check if IE is already version 11.  If it is, do nothing.
$targetIEVer = 11
$x64IEPath = "C:\Program Files\Internet Explorer\iexplore.exe"
$x86IEPath = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
if (([int](get-item $x64IEPath).VersionInfo.productVersion.split('.')[0] -ge $targetIEVer) -or ([int](get-item $x86IEPath).VersionInfo.productVersion.split('.')[0] -ge $targetIEVer)){
    Write-Host "IE11 Already installed - no action taken"
}
else{

    $fileroot = split-path $script:MyInvocation.MyCommand.Path -parent # sets the target directory to where the .ps1 is.
    $os = (Get-WmiObject Win32_OperatingSystem -computername localhost).OSArchitecture
    try {
        if ($os -eq "32-Bit" -and (Test-Path $fileroot) -eq $true)
        {

            Write-Host "Found 32-Bit Architecture...Installing pre-requisite updates..."

            #Prerequisite Patches
            $updateMSU = @(
                "Windows6.1-KB2533623-x86.msu",
                "Windows6.1-KB2888049-x86.msu",
                "Windows6.1-KB2670838-x86.msu",
                "Windows6.1-KB2729094-v2-x86.msu",
                "Windows6.1-KB2731771-x86.msu",
                "Windows6.1-KB2786081-x86.msu",
                "Windows6.1-KB2834140-v2-x86.msu",
                "Windows6.1-KB2882822-x86.msu",
                "Windows6.1-KB2639308-x86.msu"
            )
            $ie32 =  "EIE11_EN-US_MCM_WIN7.EXE" #Installer 

            foreach ($updateMSU in $updateMSUs){
                Write-Host "Installing Update $updateMSU..."
                Start-Process "wusa.exe" -ArgumentList @("""$fileroot\$updateMSU""","/quiet","/norestart") -Wait -Verbose
            }

            Write-Host "Stopping any active IE processes..."
            get-process iexplore -ErrorAction silentlycontinue | Stop-Process -ErrorAction SilentlyContinue
            Write-Host "Installing Internet Explorer 11, 32-bit...Please Wait"
            Start-Process "$fileroot\$ie32" -ArgumentList @("/passive","/update-no","/norestart") -Wait -verbose

            Exit 0

        }
    }
    catch {
        throw "Error installing IE 11"
    }

    #######################################################################################
    #                                IE 64-bit Routine
    #######################################################################################
    try{
        if ($os -eq "64-Bit" -and (Test-Path $fileroot) -eq $true)
        {
            Write-Host "Found 64-Bit Architecture...Installing pre-requisite updates..."

            #prerequisite patches
            $updateMSUs = @(
                "Windows6.1-KB2533623-x64.msu",
                "Windows6.1-KB2888049-x64.msu",
                "Windows6.1-KB2670838-x64.msu",
                "Windows6.1-KB2729094-v2-x64.msu",
                "Windows6.1-KB2786081-x64.msu",
                "Windows6.1-KB2834140-v2-x64.msu",
                "Windows6.1-KB2882822-x64.msu",
                "Windows6.1-KB2639308-x64.msu"
            )
            $ie64 = "IE11-Windows6.1-x64-en-us.exe" #Installer

            foreach ($updateMSU in $updateMSUs){
                Write-Host "Installing Update $updateMSU..."
                Start-Process "wusa.exe" -ArgumentList @("""$fileroot\$updateMSU""","/quiet","/norestart") -Wait -Verbose
            }


            Write-Host "Stopping any active IE processes..."
            get-process iexplore -ErrorAction silentlycontinue | Stop-Process -ErrorAction SilentlyContinue
            Write-Host "Installing Internet Explorer 11, 64-Bit, Please wait..."
            Start-Process "$fileroot\$ie64" -ArgumentList @("/passive","/update-no","/norestart") -Wait -verbose
            if ($?){Write-Host "Install complete"}
            Exit 0
        }
    }
    catch {
            throw "Error installing IE 11"
    }
}
