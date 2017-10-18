function ConvertTo-Unix {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true, Mandatory=$true)]
        [Alias("PSPath")]
        [string]$Path
    )
    process {
        if(Test-Path $Path) {
            Set-Content $Path ([System.Text.Encoding]::UTF8.GetBytes(((Get-Content $Path -Raw) -replace "\r?\n","`n"))) -Encoding Byte
        } else {
            Write-Error "Cannot find path '$Path' because it does not exist."
        }
    }
}
