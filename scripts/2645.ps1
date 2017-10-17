Function Get-ApplicationPath {
    Param ([string[]]$extension)
    Write-Verbose "Saving current location"
    Push-Location
    
    $extension | % {
        try {
            Set-Location "HKLM:\Software\Classes\$($_)" -ErrorAction Stop
            $default = (Get-ItemProperty -Path $pwd.Path -Name '(Default)').'(Default)'
            
            try {
                Set-Location "HKLM:\Software\Classes\$($default)\shell\open\command" -errorAction Stop
                (Get-ItemProperty -Path $pwd.Path -Name '(Default)').'(Default)' -match '([^"^\s]+)\s*|"([^"]+)"\s*' | Out-Null
                $path = $matches[0].ToString()
        
                New-Object PSObject -Property @{
                    "Extension" = $_
                    "AppPath" = $path
                }
            }
            catch {
                Write-Error $_
            }
        }
        catch {
            Write-Error $_
        }    
    }
    Pop-Location
}
