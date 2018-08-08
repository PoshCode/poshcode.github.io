function Get-ReversedString {
  <#
    .EXAMPLE
        PS C:\>Get-ReversedString ".gnirts gnol hcum oot ,gnol yrev ,gnol ,gnol ,gnol a si sihT"
  #>
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory=$true,
               Position=0,
               ValueFromPipeline=$true)]
    [String]$InputString
  )
  
  if ($PSCmdlet.ShouldProcess($InputString, "Get reversed version of string")) {
    [Array]::Reverse(($arr = $InputString -split ''))
    return (-join $arr)
  }
}
