$items = ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items())

$dasReport = @()

$items | foreach {
    
    $itemName = $_.name
        
        $_.verbs() | foreach {

        $properties = @{
                    "Verbs"=$_.name
                    "Name"=$itemName
                    }
        
            $object = New-Object –TypeName PSObject –Prop $properties
            $dasResult = Write-Output $object
            $dasReport += $dasResult
            }
        }
