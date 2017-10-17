function Convert-StringSID {
<#
.Synopsis
  Takes a SID string and outputs a Win32_SID object.

.Parameter sidstring
  The SID in SDDL format. Example: S-1-5-21-39260824-743453154-142223018-195717

.Description
  Takes a SID string and outputs a Win32_SID object.
  Note: it also adds an extra property, base64_sid, the base64 representation
        of the binary SID.

.Example
PS> Convert-StringSID 'S-1-5-21-39260824-743453154-142223018-195717'

.Example
PS> $list_of_sids |
      Convert-StringSID |
      %{Write-Output "$($_.ReferenceDomainName)\$($_.AccountName)"}
MYDOMAIN\somename
MYDOMAIN\anotheraccount

.Notes
  NAME:      Convert-StringSID
  AUTHOR:    tojo2000
#Requires -Version 2.0
#>
  param([Parameter(Position = 0,
                   Mandatory = $true,
                   ValueFromPipeline = $true]
        [string]$sidstring)

  BEGIN {}

  PROCESS{
    [wmi]$obj = 'Win32_SID.SID="{0}"' -f $sidstring
    $encoded = [System.Convert]::ToBase64String($obj.BinaryRepresentation)
    $obj |
      Add-Member -MemberType NoteProperty -Name base64_sid -Value $encoded
    Write-Output $obj
  }

  END{}
}
