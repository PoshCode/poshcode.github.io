$script:dse = 'LDAP://my.domain.com'

function script:User-Exists([string]$username)
{
  $username = $($username).Trim()
  $srch = New-Object DirectoryServices.DirectorySearcher $global:dse
  $srch.Filter = "(&(objectClass=user)(sAMAccountName=$username))"
  $srch.PageSize = 10000
  $srch.SearchScope = "Subtree"
  return ($srch.FindOne() -ne $null)
}

function script:Get-User([string]$username)
{
  $username = $($username).Trim()
  $srch = New-Object DirectoryServices.DirectorySearcher $global:dse
  $srch.Filter = "(&(objectClass=user)(sAMAccountName=$username))"
  $srch.PageSize = 10000
  $srch.SearchScope = "Subtree"
  return ( New-Object DirectoryServices.DirectoryEntry $srch.FindOne().Path, $adUsername, $adPassword )
}

function script:Group-Exists([string]$group)
{
  $group = $($group).Trim()
  $srch = New-Object DirectoryServices.DirectorySearcher $global:dse
  $srch.Filter = "(&(objectClass=group)(samAccountName=$group))"
  $srch.PageSize = 10000
  $srch.SearchScope = "Subtree"
  return ($srch.FindOne() -ne $null)
}
 
function script:Get-Group([string]$group)
{
  $group = $($group).Trim()
  $srch = New-Object DirectoryServices.DirectorySearcher $global:dse
  $srch.Filter = "(&(objectClass=group)(samAccountName=$group))"
  $srch.PageSize = 10000
  $srch.SearchScope = "Subtree"
  return ( New-Object DirectoryServices.DirectoryEntry $srch.FindOne().Path, $adUsername, $adPassword )
}

function script:AddTo-Group([System.DirectoryServices.DirectoryEntry]$object, [System.DirectoryServices.DirectoryEntry]$group)
{
  if (-not (Object-IsMemberOf $object $group)) {
    try {
      $group.Add($object.adsPath) 
      $group.SetInfo() 
      $global:status += '<li style="color:green">The Object ' +$($object.Name)+ ' was successfully added to the Group ' +$($group.Name)+'</li>' }
    catch {
      $global:flagMail = $true
      $global:status += '<li style="color:red">The Object ' + $($object.Name) + ' could NOT be added to the Group ' + $($group.Name)+'. Error: Security rights error!</li>' }
  }
}

function Global:Object-IsMemberOf([DirectoryServices.DirectoryEntry]$object, [DirectoryServices.DirectoryEntry]$group)
{
  $result = $false
  foreach($dn in $object.Properties["memberOf"]) {
    if ($group.distinguishedName -eq $dn) {
      $result = $true }
  }
  return $result
}

