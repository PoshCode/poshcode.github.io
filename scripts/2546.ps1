function Set-ToStringMethod {

<#
    .Synopsis
        Overwrites default .ToString() method of a given type.
    .Description
        Some commands use .ToString() method of an object to produce output.
        Default (inherited from System.Object) result of that method is object's type FullName.
        That is usually not very interesting and useful - thus need to replace it with something else.
        Use $this special variable inside ScriptBlock to refer to object's properties and methods.
    .Example
        Set-ToStringMethod -TypeName System.Array -ScriptBlock { ($this | foreach { $_.ToString() ) -Join ';' }
        
        Results of:
        (1,2,3,4,(Get-Date)).ToString()
        Before:
        System.Object[]
        After:
        1;2;3;4;07/03/2011 23:09:20
        
        What do you prefer? Meaningless name of the type or string representation of members? Choice is yours... ;)
#>

[CmdletBinding()]
param (
    # Name of type to be modified.
    [Parameter(Mandatory = $true)]
    [string]$TypeName,
    # Scriptblock that will be used as .ToString() method.
    [Parameter()]
    [scriptblock]$ScriptBlock = { $this.Name }
)

    if ($TypeName -eq 'System.Object') {
        # To many types depend on this object's ToString method - most likely it will kill your shell. :(
        throw "Suicide action detected... I quit! :P"
    }

    $XML = @"
<Types>
    <Type>
        <Name>$TypeName</Name>
        <Members>
            <ScriptMethod>
                <Name>ToString</Name>
                <Script>
                    $ScriptBlock
                </Script>
            </ScriptMethod>
        </Members>
    </Type>
</Types>
"@

    $XMLFile = [io.path]::GetTempFileName() + '.ps1xml'
    try {
        New-Item -ItemType File -Path $XMLFile -Value $XML | Write-Verbose
        Update-TypeData -PrependPath $XMLFile -ErrorAction Stop
    } catch {
        # One day I will do something wiser than that... ;)
        Write-Error $_
    }
}
