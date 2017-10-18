Function Get-Software{
    <#
    .SYNOPSIS
        Gets the software applications on a remote computer.
    .DESCRIPTION
        This function interrogates the remote registry for installed software products.
        It then returns an array of powershell objects that can be sorted and parsed.
        
        Optionally, you can provide a product name that will filter applications based on
        displayname before they are returned, thus reducing the typing needed to get specific results.
    .PARAMETER computer
        The name of the computer to retrieve a software list from.
    .PARAMETER product
        The partial name of a software application to search for.
    .INPUTS
    .OUTPUTS
    .NOTES
        Name: Get-Software
        Author: Geoffrey Guynn
        DateCreated 9 Aug 2011
    .EXAMPLE
        Get-Software -computer "computer" -name "Adobe"
        Returns all instances of Adobe software on the computer.
    #>

    [cmdletbinding(
        SupportsShouldProcess = $True,
        DefaultParameterSetName = "process",
        ConfirmImpact = "low"
    )]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Computer
        ,
        [string]$Product
    )
    #Get Architechture Type of the system
    $OSArch = (Gwmi -computer $Computer win32_operatingSystem).OSArchitecture
    if ($OSArch -like "*64*") {$Architectures = @("32bit","64bit")}
    else {$Architectures = @("32bit")}
    #Create an array to capture program objects.
    $arApplications = @()
    foreach ($Architecture in $Architectures){
        #We have a 64bit machine, get the 32 bit software.
        if ($Architecture -like "*64*"){
            #Define the entry point to the registry.
            $strSubKey = "SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
            $SoftArchitecture = "32bit"
            $RegViewEnum = [Microsoft.Win32.RegistryView]::Registry64
        }
        #We have a 32bit machine, use the 32bit registry provider.
        elseif ($Architectures -notcontains "64bit"){
            #Define the entry point to the registry.
            $strSubKey = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
            $SoftArchitecture = "32bit"
            $RegViewEnum = [Microsoft.Win32.RegistryView]::Registry32
        }
        #We have "64bit" in our array, capture the 64bit software.
        else{
            #Define the entry point to the registry.
            $strSubKey = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
            $SoftArchitecture = "64bit"
            $RegViewEnum = [Microsoft.Win32.RegistryView]::Registry64
        }
        #The standard routine to get software.
        #************************************************************************
        #Create a remote registry connection to the server.
        $remRegistry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer, $RegViewEnum)
        #Open the entry point.
        $remKey = $remRegistry.OpenSubKey($strSubKey)
        #Get all subkeys that exist in the entry point.
        $remSoftware = $remKey.GetSubKeyNames()
        #Loop through the applications and capture data.
        foreach ($remApplication in $RemSoftware){
            $remProgram = $remRegistry.OpenSubKey("$strSubKey\\$remApplication")
            $strDisplayName = $remProgram.GetValue("DisplayName")
            if ($strDisplayName){
                #Get a list of all available properties for the program.
                $arProperties = $remProgram.GetValueNames()
                #Create a custom object for this program.
                $objApplication = New-Object System.Object
                #Write-Host "`n"
                foreach ($strProperty in $arProperties){
                    #Get the value associated with the current property.
                    $strValue = [string]($remProgram.GetValue($strProperty))
                    if ($strValue){
                        #If the property has a value but no name, then it is the default property.
                        if (!$strProperty){
                            $objApplication | Add-Member -type NoteProperty -Name "(Default)" -Value $strValue
                        }
                        #The property has a value and a name, assign them both as a new property on the object.
                        else{
                            $objApplication | Add-Member -type NoteProperty -Name ([string]$strProperty) -Value $strValue
                        }
                    }
                    #Write-Host $strValue ": " $remProgram.GetValue($strValue)
                }
                #Add a final property to denote the software architecture type.
                $objApplication | Add-Member -type NoteProperty -Name "Architecture" -Value $SoftArchitecture
                #Add the last application to the array of programs.
                $arApplications += $objApplication
            }
        }
    }
    if ($Product){
        $objApplication = $arApplications | ? {$_.DisplayName -Like "*$Product*"} | Sort-Object -property Architecture,DisplayName
        return $objApplication
    }
    #Sort the array by each object's Architecture and DisplayName.
    $arApplications = $arApplications | Sort-Object -property Architecture,DisplayName
    return $arApplications
}
