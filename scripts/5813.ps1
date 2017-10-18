<#  This scriptlet is a table driven template tool. 
    It's a refinement of an earlier attempt.

    It generates an output file from a template and
    a driver table.  The template file contains plain
    text and embedded variables.  The driver table has
    one column for each variable, and one row for each
    expansion to be generated.

    2/15/2015
  
#>

param ($driver, $template, $out);

$OFS = "`r`n"
$list = Import-Csv $driver
[string]$pattern = Get-Content $template
Clear-Content $out -ErrorAction SilentlyContinue

foreach ($item in $list) {
   foreach ($key in $item.psobject.properties) {
      Set-variable -name $key.name -value $key.value
      }
   $ExecutionContext.InvokeCommand.ExpandString($pattern)  >> $out
   }

