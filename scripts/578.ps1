## Get-DistinguishedName -- look up a DN from a user's (login) name 
function Get-DistinguishedName { 
Param($UserName)
   $ads = New-Object System.DirectoryServices.DirectorySearcher(([ADSI]''))
   $ads.filter = "(&(objectClass=Person)(samAccountName=us321339))"
   $s = $ads.FindOne()
   return $s.GetDirectoryEntry().DistinguishedName
}

## Get-GroupMembership -- Get AD group membership recursively
function Get-GroupMembership {
Param($DNName,[int]$RecurseLimit=-1)

   $groups = ([adsi]"LDAP://$DNName").MemberOf
   if ($groups -and $RecurseLimit) {
      Foreach ($gr in $groups) {
         $groups += @(Get-GroupMembership $gr -RecurseLimit:$($RecurseLimit-1) |
                    ? {$groups -notcontains $_})
      }
   }
   return $groups
}

## Usage:
#################################################################################
## $groups = Get-GroupMembership (Get-DistinguishedName Jaykul)
## # To turn recursion off:
## $groups = Get-GroupMembership (Get-DistinguishedName Jaykul) -recurse 0 
