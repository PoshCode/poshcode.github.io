param($computer,$instance,$database)

import-module sqlps -disablenamechecking

$path = "SQLSERVER:\SQL\$($computer)\$($instance)\Databases\$($database)\Tables"
SET-LOCATION $path
get-childitem | where {$_.HasCompressedPartitions -or $_.IsPartitioned} | 
select @{n='ServerInstance';e={"$computer\$instance"}},@{n='Database';e={$database}}, name, HasCompressedPartitions, IsPartitioned
cd $home
