## Dane Kantner 4/19/2013
##

$computers="localhost","Chiv5908-2009","anyothercomputers","NYSPC-JJAJ68YG6"

foreach ($computer in $computers) {

$obj=get-wmiobject win32_systemenclosure -computername $computer -ErrorAction SilentlyContinue

    if ($obj -eq $null) {  # unable to retrieve, system may be offline
        write-output "Computer $computer unavailable (offline or WMI inaccessible).`n"
    } else {
        $WarrantyObject=Get-DellWarranty -ServiceTag $obj.SerialNumber | select @{name = "ComputerName";expression = {$Computer}},ServiceLevelCode,ServiceLevelDescription,Provider,StartDate,EndDate,DaysLeft,EntitlementType   

        #each computer itself will have a $warrantyobject returned that can have multiple warranty lines attached.
        #based off of this you can do various output scenarios. 
        $DaysLeft=0
        $HighestServiceDesc=""
        foreach ($line in $WarrantyObject) {
            if ($line.ServiceLevelCode -ne $Null) { #The last line is a null line from the dell service, discard with an if neq null check
                if ($DaysLeft -lt $line.DaysLeft) { #this warranty lasts longer than the prior line item for this computer.
                $DaysLeft=$line.DaysLeft
                $HighestServiceDesc=$line.ServiceLevelDescription
                }
            write-output $line
            #you could output it to a file here instead -- or instead when calling script do scripts.ps1 > filenametosave.txt
            }
        } #end foreach $warrantyobject
        
        # in this coding scenario, an HP computer would just return a null object.
        if ($warrantyObject -ne $null) { 
            write-output "Maximum warranty for computer $Computer has $DaysLeft days remaining. $HighestServiceDesc`n"
        } else {
            write-output "Dell returned no warranty information for $Computer. Is it a Dell?"   
        } #end if WarrantyObject is not null
       
      
    } #end if obj null because WMI failed to retrieve serial
} #end foreach computer


Function Get-DellWarranty {
## This function was created based off of modifying code from http://itx-solutions.nl/2013/01/dell-powershell-script-to-get-dell-warranty-information/
    [CmdletBinding()]
        param(
            [Parameter(Mandatory=$False,Position=0,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
            [alias("serialnumber")]
            [string[]]$ServiceTag
        )
    $WebProxy=New-WebServiceProxy -Uri http://xserv.dell.com/services/assetservice.asmx
    $WarrantyInformation=$WebProxy.GetAssetInformation(([guid]::NewGuid()).Guid,"Dell warranty",$serviceTag)
    $WarrantyInformation | Select-Object -ExpandProperty Entitlements
    return $WarrantyInformation
}
