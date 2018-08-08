Import-Module DistributedCacheAdministration
Use-CacheCluster
$c = Get-CacheHost
$d=$c[0].Status
