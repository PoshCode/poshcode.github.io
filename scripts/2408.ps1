# .Summary
# Download and execute a script block from PoshCode.org
# .Description
# Download the code for a PoshCode script based on search of by specific index.
# Execute the code as a script block, passing arguments to it.
#
# Note: this is scary, and you should only use it if you really know what you're doing ;) By invoking the downloaded code as a script block, we effenctively bypass the execution policy...
#
# Depends on the PoshCode module from http://poshcode.org/PoshCode.psm1
#
# .Parameter SearchTerms
# The terms to use when searching, or the Id of the spu
# .Parameter ArgumentList
# The arguments to be passed to the Invoked script
# .Example
# Invoke-PoshCode Test-Port localhost 80
#
# Search for "Test-Port" and invoke the first result with the parameters "localhost" and 80
# .Example
# Invoke-PoshCode 85 localhost 80
#
# Fetch http://poshcode.org/get/85 and invoke it with the parameters "localhost" and 80
# .Example
# Invoke-PoshCode 85 -ArgumentList @{srv="localhost";port="80"}
#
# Fetch http://poshcode.org/get/85 and invoke it with the parameters srv = "localhost" and port = 80
function Invoke-PoshCode {
param(
   [Parameter(Mandatory=$true, Position=1)]$SearchTerms, 
   [Parameter(Position=2, ValueFromRemainingArguments=$true)]$ArgumentList)
   Write-Verbose "Searching for: $SearchTerms"
   if($SearchTerms -is [int]) {
      $Code = Get-PoshCode -Id $SearchTerms -Passthru
   } else {
      $Code = Get-PoshCode -Query $SearchTerms | Select -First 1 | Get-PoshCode -Passthru
   } 
   Invoke-Command -ScriptBlock ([ScriptBlock]::Create($Code)) -ArgumentList $ArgumentList
}
