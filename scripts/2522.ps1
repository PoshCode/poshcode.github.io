﻿#this function takes nested hashtables and converts them to nested pscustomobjects
#it can also contain arrays of hashtables, and it will turn those hashtables in the arrays
#also into PScustomobjects
function new-pshash 
{
[CmdletBinding()]
PARAM(
[parameter(valuefromPipeline=$true,Mandatory=$true, position = 1)]
[HashTable]$fromHashTable,
[Parameter(position = 2)]
[String]$typename

)
process { 
    
    $obj = new-object pscustomobject -Property $fromhashtable
    if ($typename) { $obj.psobject.typenames.insert(0,$typename) } 
    foreach($prop in $obj.psobject.properties)
    {
     if ($prop.value -is [hashtable])
        {            
            $obj.$($prop.name) = new-pshash $($obj.$($prop.name))            
        } else
        {                  
         if ($prop.value -is [Object[]])
            {                
                $k2 = $obj.($prop.name).count
                for($index = 0; $index -lt $obj.($prop.name).count; $index++)
                {                                                    
                  if ($obj.($prop.name)[$index] -is [hashtable])
                   {         
                      $obj.$($prop.name)[$index] =  new-pshash $obj.$($prop.name)[$index]                                              
                   }                
                }
            }
        }       
    }
    $obj
 }

}

#test object, hash of hashes of arrays of hashes
$testobject = @{
 top1 = 1
 #nested of nested
 nested = @{ nest = 'two'
             deepernest = @{ deepest = 1; whoohoo = 2 }
 }
 simplearray = ( 1 , 2 , 3 )
 hasharray = (
              @{ name = 'karl'
                 age = '30' },
              @{ name = 'john'
                 age = '40' }
             )
}

 
 
 $a = new-pshash $testobject karlclass
 $a
