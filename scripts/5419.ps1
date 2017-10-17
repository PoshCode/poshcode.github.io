function Search-PoshcodeScript {
  <#
    .EXAMPLE
        PS C:\> Search-PoshcodeScript "logon users"
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true)]
    [String]$ScriptName
  )
  
  &(([Regex]"(?<=`")(.*)(?=`"\s)").Match(
    (cmd /c ftype (cmd /c assoc .html).Split('=')[1])
  ).Value) ('http://poshcode.org/?lang=&q=' + $ScriptName -replace '\s', '+')
}
