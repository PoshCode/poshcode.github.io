Function Add-Counter {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)] $input,
        [string] $Name='Count'
    )
    BEGIN { $i = 0;}
    PROCESS {
        $i++;
        return Add-Member -InputObject $_ -MemberType NoteProperty -Name $Name -Value $i -PassThru
    }
}

