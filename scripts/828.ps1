# Function New-CustomColumn for PowerShell V1.0
#
# Helper function to create Custom Columns for select or format cmdlets
# for more info and examples see :
# http://thepowershellguy.com/blogs/posh/archive/2009/01/26/new-customcolumn-function-powershell-v1-0.aspx
#
# /\/\o\/\/ 2008
# http://thePowerShellGuy.com

Function New-CustomColumn {
  PARAM (
    $Expression,
    $name,
    $label,
    $FormatString,
    [int]$Width,
    $Alignment
  )

  $column = @{}

  if ($Expression){
    $Column.Expression = $Expression
  } else {
    throw "Expression is mandatory"
  }
  if ($Name) {$Column.Name = $name}
  if ($Label) {$Column.Label = $Label}
  if ($FormatString) {$Column.FormatString = $FormatString}
  if ($Width) {$Column.Width = $Width}
  if ($Alignment) {$Column.Alignment = $Alignment}

  $Column.psobject.baseobject

}
