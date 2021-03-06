#user selector Script
clear
#First Time Load

#endless loop

function makeBalloon() #Function to Notifiy by Systray Balloon
{
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon 

$objNotifyIcon.Icon = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\SetupCache\Client\Graphics\rotate1.ico"

$objNotifyIcon.BalloonTipIcon = "Info" 
$objNotifyIcon.BalloonTipText = $balloonAlert 
$objNotifyIcon.BalloonTipTitle = "Xen User is logged in."

$objNotifyIcon.Visible = $True 
$objNotifyIcon.ShowBalloonTip(1000)
}


Function LoadModules() #==========Detect Citrix Modules, load if not already loaded
{
    $ErrorActionPreference = "SilentlyContinue"
    Get-XAFarm | Out-Null
    [string]$citrixModLoad = $?
        if($citrixModLoad -eq "False"){
            "Loading Modules"
            add-pssnapin Citrix.*
            [string]$citrixModLoad = $?
         }ELSE{
            "Modules Loaded"
        }
    $ErrorActionPreference = "Continue"
} #End of LoadModules Function

function config

{
    write-host "XenUserWatch - Watches for User to Log On" -ForegroundColor Cyan
$acctInput = read-host "Enter the EXACT Account Name"
" "
$XenUser = "$acctInput"
$domain = "conseco\"
checkUser
}


function wait(){
    Start-Sleep -s 120
}

function checkUser()
{while($true)
    {
    $xsession = Get-XASession | Where-Object {$_.AccountName -eq "$domain$XenUser"} | Select-Object AccountName, SessionId, ServerName

        if (($xsession | measure-object | select-object -expand Count) -gt 1) { #If Multiple Accounts Found

                    # List Users with a coresponding Number for selection

                clear

                write-host "Multiple Accounts Found. Please try again." -ForegroundColor Red

        } ELSEIF (($xsession | measure-object | select-object -expand Count) -eq 1) { #If One Account Found

            $result = $xsession

            clear

            Write-host $result.AccountName "is logged into" $result.ServerName -ForegroundColor Green

            date

            $an = $result.AccountName

            $sn = $result.ServerName



            $balloonAlert = "$an is logged into $sn"

            makeBalloon

            "Will check again in 120 seconds, or press 'ctrl-c' to cancel"

            wait

            checkUser

        

        } ELSE { #If No Accounts Found

        clear

        write-host "$domain$XenUser is not currently logged in." -ForegroundColor Red

        date

        "Will check again in 120 seconds, or press 'ctrl-c' to cancel"

        " "

        wait

        checkUser

        }

    }



}

LoadModules

config
