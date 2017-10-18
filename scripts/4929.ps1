        [parameter(ParameterSetName='Convert')]
        [string]
        [ValidateScript({
            #Check to see if the edition is in the iso... if not, list valid editions.
            $ValidChoices = @( (Get-WinEdition -path $SourcePath).ImageFlags | ?{$_} )
            if($ValidChoices -contains $_)
            {
                $true
            }
            else
            {
                Write-Warning "Edition '$_' is not present. Valid choices:`n$($ValidChoices | Out-String)"
                Throw "Edition '$_' is not present."
            }
        })]
        $Edition=$null,
