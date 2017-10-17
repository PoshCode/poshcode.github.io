function where-in {
[cmdletbinding()]
param (
[parameter(mandatory = $true,position = 1)]
[system.Collections.IEnumerable]$collection,
[parameter(position = 2)]
[scriptblock]$predicate ,
[parameter(valuefrompipeline = $true)]
$pipelineobject
)
    process {
        if ($predicate) {
            foreach ($__ in $collection) {
                if(&$predicate) { 
                    write-Output $pipelineobject
                    break;
                }
            }
        }
        else {        
            if ($collection -contains $pipelineobject) {
            write-Output $pipelineobject }
        }
    }
}
set-alias ?in where-in

$a = (1..10) , (1..10) | % { $_ }
$a | Where-in (3,4,8)


gps | where-in  ("power","s")  { $_.processname.startswith($__) }

function where-propertyin {
[cmdletbinding()]
param (
[parameter(mandatory = $true,position = 1)]
[system.Collections.IEnumerable]$collection,
[parameter(mandatory = $true,position = 2)]
[string] $propertyname,
[parameter(position = 3)]
[scriptblock]$predicate ,
[parameter(valuefrompipeline = $true)]
$pipelineobject
)
    process {
        if ($predicate) {
            foreach ($__ in $collection) {
                $_ = $pipelineobject.$propertyname
                if(&$predicate) { 
                    write-Output $pipelineobject
                    break;
                }
            }
        }
        else {        
            if ($collection -contains $pipelineobject.$propertyname) {
            write-Output $pipelineobject }
        }
    }
}
set-alias ?.in where-propertyin

gps | where-propertyin ("powershell","svchost") processname 
gps | where-propertyin ("power","s") processname { $_.startswith($__) }

