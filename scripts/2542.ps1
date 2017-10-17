#groups by a set of properties, but returns then rather than as a string, as seperate properties on an object with _count , and _group for the original
#ones returned from group object

function group-byobject {
[CmdletBinding()]
param(
  [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
  $InputObject
, 
  [Parameter(Position=0)]
  [object[]]$property
, 
  [switch]$includeGroup
, 
  [switch]$includeCount
)
begin   { 
  $InputItems = @() 
  $select = $property
  if ($includeCount){ $select += @{ n="_count"; e={$group.count} } }
  if ($includeGroup){ $select += @{ n="_group"; e={$group.group} } }
}
process { $InputItems += $InputObject }
end {
  foreach($group in $InputItems | group-object $property) { 
    $group.Group[0] | Select $select 
  }
}
}

set-alias groupby group-byobject
set-alias grby group-byobject
