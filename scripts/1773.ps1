# v2.0

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
        
    # find out which global functions might get clobbered
    $test = new-module -ascustomobject {
        param($metadata)
        
        $clobbered = @{}
        
        # grab copies of functions that would get clobbered
        $metadata.GetExportedFunctions() | ? {
            Test-Path "function:$($_.name)"
        } | % {    
            $clobbered[$_.name] = gc -path "function:$($_.name)"
        }
        
        function GetClobberedFunctions() {
            $clobbered
        }
        
    } -args $metadata

    # import module
    $m = import-module $ModuleName -PassThru

    # grab clobberable (!) functions
    $clobbered = $test.GetClobberedFunctions()
        
    # hook up function restore
    $m.onremove = {
        $clobbered.keys | % {
            si -path function:global:$_ $clobbered[$_] -force
        }
    }.getnewclosure()
}
