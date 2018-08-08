function Push-Module {
    param(
        [parameter(position=0, mandatory=$true)]
        [validatenotnullorempty()]
        [string]$ModuleName
    )
    
    # find out what this module exports (and therefore what it overwrites)
    $metadata = new-module -ascustomobject {
        param([string]$ModuleName)
        
        # import targeted module
        $inner = import-module $ModuleName -PassThru       

        function GetExportedFunctions() {
            $inner.ExportedFunctions.values
        }
        
        # prevent export of inner module's exports
        Export-ModuleMember -Cmdlet "" -Function GetExportedFunctions
        
    } -args $ModuleName

    $clobbered = @{}
    
    # grab copies of functions that would get clobbered
    $metadata.GetExportedFunctions() | ? {
        Test-Path "function:$($_.name)"
    } | % {    
        $clobbered[$_.name] = gc -path "function:$($_.name)"
    }
        
    # import module
    $m = import-module $ModuleName -PassThru
    
    # hook up function restore
    $m.onremove = {
        $clobbered.keys | % {
            si -path function:global:$_ $clobbered[$_] -force
        }
    }.getnewclosure()
}

