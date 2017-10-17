Function Test-VM
{
    [cmdletbinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=1)]
        [string[]]$Name,
        [Parameter(Mandatory=$true,Position=2)]
        [string[]]$ComputerName
    )
    Process
    {
        $results = @()
        foreach ($cName in $ComputerName) {
            foreach ($vName in $Name) {
                $result = New-Object System.Management.Automation.PSObject
                $result | Add-Member -NotePropertyName ComputerName -NotePropertyValue $cName
                $result | Add-Member -NotePropertyName Name -NotePropertyValue $vName
                Try
                {
                    $vm = Get-VM -ComputerName $cName -Name $vName -ErrorAction SilentlyContinue
                    if ($vm -ne $null) {
                        $Existence = $true
                    } else {
                        $Existence = $false
                    }
                }
                Catch
                {
                    #Display an error message
                }
                $result | Add-Member -NotePropertyName Existence -NotePropertyValue $Existence
                $results += $result
            }
        }
        return $results
    }
}
