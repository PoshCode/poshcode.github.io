function exit-CurrentUser
{
  <#
    .SYNOPSIS
        Force current logon user logoff; be careful, there is no warning will be given to user!!

    .EXAMPLE
        Exit-CurrentUser -computer com1
  #>
    param (
        [parameter(
            Mandatory = $true,
            ValueFromPipeline=$true)]
        [string[]]
        $computers
    )
    foreach ($computer in $computers) {
        [Void](gwmi -Class Win32_OperatingSystem -ComputerName $computer).Win32Shutdown(4)
    }
}
