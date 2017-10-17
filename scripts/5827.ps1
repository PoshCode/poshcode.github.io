function Get-Monitor{
    [cmdletbinding()]
 
    Param(
        [Parameter(Mandatory=$True,Position=0)]
        [string[]]$ComputerName
    )
 
    Begin{}
 
    Process{
        Foreach($Computer in $ComputerName){
            If(Test-Connection -ComputerName $Computer -Count 1 -Quiet){
                Try{
                    $Monitors = get-wmiobject -ComputerName $Computer -ClassName wmimonitorid -Namespace root/wmi -ErrorAction Stop
                    Foreach($Monitor in $Monitors){
                        $Model = [System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName)
                        $SerialNumber = [System.Text.Encoding]::ASCII.GetString($Monitor.SerialNumberID)
                        New-Object -TypeName PSCustomObject -Property @{
                            ComputerName = $Computer
                            Model = $Model
                            SerialNumber = $SerialNumber
                        }
                    }
                }
                Catch{
                    Write-Warning -Message "Cannot query WMIMonitorID WMI class on $Computer. $($_.Exception.Message)"
                }
            }
            Else{
                Write-Warning -Message "Connection to remote server $Computer failed."
            }
        }
    }
 
    End{}
}
