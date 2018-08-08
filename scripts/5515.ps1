function Invoke-LateBoundMember {
    [cmdletbinding(supportsshouldprocess)]
    param(
        [parameter(valuefrompipeline, mandatory)]
        [validatenotnull()]
        [psobject[]]$InputObject,

        [parameter(mandatory, position=0)]
        [validatenotnullorempty()]
        [string]$MemberName,

        [parameter(position=1, valuefromremainingarguments)]
        [object[]]$ArgumentList,

        [parameter()]
        [switch]$Static,

        [parameter()]
        [switch]$IgnoreReturn
    )

    begin {
        add-type -AssemblyName Microsoft.VisualBasic
        $vbbinder = [Microsoft.VisualBasic.CompilerServices.NewLateBinding]
    }
    
    process {

        foreach ($element in $InputObject) {

            $instance = $null
            $type = $null
            if ($Static) { $type = $element } else { $instance = $element }

            # this lets us know if 
            $copyBack = new-object bool[] $ArgumentList.Length
            
            # unwrap [ref] args

            # can't use pipeline here as the new array elements get wrapped in psobject
            # this is a problem because the .net method binder won't unwrap if the destination
            # is typed as object (because psobject is compatible with this signature, right?)            
            #$unwrapped = $argumentlist | % { if ($_ -is [ref]) { $_.value } else { $_ } }
            
            $unwrapped = new-object object[] $ArgumentList.Count
            
            if ($ArgumentList) {
                [array]::Copy($ArgumentList, $unwrapped, $ArgumentList.length)
                for ($i = 0; $i -lt $ArgumentList.Length; $i++) {
                    if ($unwrapped[$i] -is [ref]) { $unwrapped[$i] = $unwrapped[$i].value }
                    if ($unwrapped[$i] -is [psobject]) {
                        write-warning "The argument at index $i is wrapped as a PSObject. This is almost certainly not what you want."
                    }
                }
            }

            $result = $vbbinder::LateCall(
                [object]$instance, # null if static call
                [type]$type, # null if instance call
                [string]$MemberName,
                $unwrapped,
                <# ArgumentNames #> $null, # not used
                <# TypeArguments #> $null, # let dlr infer for us
                $copyBack, # was arg modified byref?
                $IgnoreReturn.IsPresent) # should ignore/expect retval?

            # check for copyback / byref
            for ($i = 0; $i -lt $ArgumentList.Length; $i++) {
                $argument = $ArgumentList[$i]
                if ($copyBack[$i]) {
                    # update psreference
                    if ($argument -is [ref]) {
                        write-verbose "Updating [ref] at index $i"
                        $argument.value = $unwrapped[$i]
                    } else {
                        write-warning "Argument at index $i was modified. Pass the argument as a [ref] variable to receive the result."
                    }
                }
            }

            if (-not $IgnoreReturn) {
                $result
            }
        }
    }
}

New-Alias -Name ilb -Value Invoke-LateBoundMember -Force

