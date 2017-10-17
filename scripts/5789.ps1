function filecount {            
param (            
 [string]$path            
)            
 if (-not (Test-Path $path)){Throw "Path: $path not found"}            
             
 $count = 0            
 $count = Get-ChildItem -Path $path |             
          where {!$_.PSIsContainer} |             
          Measure-Object |            
          select -Expand count            
                      
 Get-Item -Path $path |           
 select PSDrive,             
 ##@{N="Parent"; E={($_.PSParentPath -split "FileSystem::")[1]}},            
 Name,            
 @{N="FileCount"; E={$count}} | Where-Object { !($_ -match 'psa4ruww') }
 Get-ChildItem -Path $path | 
            
 where {$_.PSIsContainer} |             
 foreach {
   filecount $($_.Fullname)            
 }            
            
}             
            
filecount "dir path"
