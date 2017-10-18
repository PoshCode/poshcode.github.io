function Get-NTStatusException
{
<#
.SYNOPSIS

Resolves an NTSTATUS error code.

Author: Matthew Graeber (@mattifestation)

.DESCRIPTION

Get-NTStatusException returns a friendly error message based on the NTSTATUS code passed in. This function is useful when interacting with Windows Native API functions with NTSTATUS return codes.

.PARAMETER ErrorCode

An NTSTATUS code returned by a native API function (Nt or Rtl prefixed functions)

.EXAMPLE

C:\PS> Get-NTStatusException -ErrorCode 0xC0000005
Invalid access to memory location.

.EXAMPLE

C:\PS> 0xC0000005, 0xC0000017, 0x00000000 | Get-NTStatusException
Invalid access to memory location.

Not enough storage is available to process this command.

The operation completed successfully.

.LINK

http://www.exploit-monday.com/
#>

    [CmdletBinding()] Param (
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True)]
        [Int32[]]
        $ErrorCode
    )

    BEGIN
    {
        Set-StrictMode -Version 2

        $Win32Native = [AppDomain]::CurrentDomain.GetAssemblies() | %{ $_.GetTypes() } | ? { $_.FullName -eq 'Microsoft.Win32.Win32Native' }

        if ($Win32Native -eq $null)
        {
            throw "Unable to get a reference to type: Microsoft.Win32.Win32Native"
        }

        $LsaNtStatusToWinError = $Win32Native.GetMethod('LsaNtStatusToWinError', [Reflection.BindingFlags] 'NonPublic, Static')
        $GetMessage = $Win32Native.GetMethod('GetMessage', [Reflection.BindingFlags] 'NonPublic, Static')
    }
    PROCESS
    {
        foreach ($Error in $ErrorCode)
        {
            $WinErrorCode = $LsaNtStatusToWinError.Invoke($null, @($ErrorCode))

            Write-Output $GetMessage.Invoke($null, @($WinErrorCode))
        }
    }
    END{}
}
