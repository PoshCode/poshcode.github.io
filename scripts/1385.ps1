# Lists AD users who are members in too many groups
# (c) Dmitry Sotnikov
# Details at:
# http://dmitrysotnikov.wordpress.com/2009/10/12/find-users-in-too-many-groups/
# Uses free Quest AD cmdlets

$limit = 75
Get-QADUser -SizeLimit 0 -DontUseDefaultIncludedProperties |
  ForEach-Object {
    $groups = Get-QADGroup -ContainsIndirectMember $_.DN -SizeLimit $limit `
      -DontUseDefaultIncludedProperties -WarningAction SilentlyContinue
    if ($groups.Count -ge $limit) { $_ }
  }

