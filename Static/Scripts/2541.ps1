#groups by a set of properties, but returns then rather than as a string, as seperate properties on an object with _count , and _group for the original
#ones returned from group object
#TODO: rewrite as an advanced function

function group-byobject ([object[]]$property,[switch]$includeGroup,[switch]$includeCount)
{
 $results = $input | group-object $property
 $results | % {
    $hash = @{}
    $obj = $_;
    if ($includeCount) { $hash._count = $obj.count; }
    if ($includeGroup) { $hash._group = $obj.group; }
    $property | % { $hash.$_ = $obj.group[0].$_ }
    new-object psobject -property $hash
    
 }
}
set-alias groupby group-byobject
set-alias grby group-byobject

