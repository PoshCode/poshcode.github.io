function Copy-ItemGUI
{
<#
.Synopsis
   GUI display for copy-item function
.DESCRIPTION
   Allows you to copy items and display the native windows copy dialogue instead of having to use -passthru or fuss with write-progress
.EXAMPLE
   Copy-ItemGUI -Source $Folder -Destination "C:\SomeFolder"
.NOTES
   v1.0 - 2016-01-30 - Nathan Kasco
#>
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)] #TODO: Allow only folder paths (Can we test these here and loop if path is invalid?)
        $Source,

        [Parameter(Mandatory=$true, Position=1)]
        [string]
        $Destination
    )

    #If destination does not exist, break
    #TODO: Create folder if destination does not exist
    if(!(Test-Path $Destination)){
        break
    }

    $src = gci $Source

    $objShell = New-Object -ComObject "Shell.Application"

    $objFolder = $objShell.NameSpace($Destination) 

    $counter = ($src.Length) - 1
    foreach($file in $src){
        Write-Host -ForegroundColor Cyan "Copying file '"$file.name"' to ' $Destination '"

        try{
            #Info regarding options for displayed info during shell copy - https://technet.microsoft.com/en-us/library/ee176633.aspx
            $objFolder.CopyHere("$source\$file", "&H0&")
        }
        catch{
            Write-Error $_
        }

        Write-Host -ForegroundColor Green "Copy complete - Number of items remaining: $counter`n"
        $counter--
    }
}
