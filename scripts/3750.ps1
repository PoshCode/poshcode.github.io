function Get-RecurseMember {
<#
.Synopsis
  Does a recursive search for unique users that are members of an AD group.

.Description
  Recursively gets a list of unique users that are members of the specified 
  group, expanding any groups that are members out into their member users.

  Note: Requires the Quest AD Cmdlets
        http://www.quest.com/powershell/activeroles-server.aspx

.Parameter group
  The name of the group.

.Example
PS> Get-RecurseMember 'My Domain Group'

.Notes
  NAME:      Get-RecurseMember
  AUTHOR:    tojo2000
#Requires -Version 2.0
#>
  param([Parameter(Position = 0,
                   Mandatory = $true)]
        [string]$group)
  $users = @{}
  
  try {
    $members = Get-QADGroupMember $group
  } catch [ArgumentException] {
    Write-Host "`n`n'$group' not found!`n"
    return $null
  }
  
  foreach ($member in $members) {
    if ($member.Type -eq 'user') {
      $users.$($member.Name.ToLower()) = $member
    } elseif ($member.Type -eq 'group') {
      foreach ($user in (Get-RecurseMember $member.Name)) {
        $users.$($user.Name.ToLower()) = $user
      }
    }
  }
  
  foreach ($user in $users.Keys | sort) {
    Write-Output $users.$user
  }
}
