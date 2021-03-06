#requires -version 2.0

## Version 1.0 First post https://PoshCode.org/1459
## Version 1.1 Fixed column uniqueness bug

#.Note
#  Depends on ConvertFrom-HashTable https://PoshCode.org/1118
#.Synopsis
#  Performs a inner join on two collections of objects based on a common key column.
#.Description
#  Takes two sets of objects where there are multiple "rows" and where each set has a shared column where the values match, and generates new objects with all the values from each.
#.Parameter GroupOnColumn
#  The name of the property to merge on. Items with the same value in this column will be combined.
#.Parameter FirstCollection
#  The first set of data
#.Parameter FirstJoinColumn
#  The name of the key id column in the first set
#.Parameter SecondCollection
#  The second set of data
#.Parameter SecondJoinColumn
#  The name of the matching key id column in the second set
#  OPTIONAL. Defaults to the same as FirstJoinColum
#.Example
#  Import-CSV data.csv | Pivot-Objects SamAccountName Attribute Value
#
#  Imports csv data containing multiple rows per-record such that a pair of columns named "Attribute" and "Value" are actually different in each row, and contain a name and value pair for attributes you want to add to the output objects.
#
#.Example
# $FirstCollection = @"
#  FirstName,  LastName,   MailingAddress,    EmployeeID
#  John,       Doe,        123 First Ave,     J8329029
#  Susan Q.,   Public,     3025 South Street, K4367143
#"@.Split("`n") | ConvertFrom-Csv
#
# $SecondCollection = @"
#  ID,    Week, HrsWorked,   PayRate,  EmployeeID
#  12276, 12,   40,          55,       J8329029
#  12277, 13,   40,          55,       J8329029
#  12278, 14,   42,          55,       J8329029
#  12279, 12,   35,          40,       K4367143
#  12280, 13,   32,          40,       K4367143
#  12281, 14,   48,          40,       K4367143
#"@.Split("`n") | ConvertFrom-Csv
#
# Join-Collections $FirstCollection EmployeeID $SecondCollection | ft -auto
#
#.Notes
#  Author: Joel Bennett

# function Join-Collections {
PARAM(
   $FirstCollection
,  [string]$FirstJoinColumn
,  $SecondCollection
,  [string]$SecondJoinColumn=$FirstJoinColumn
)
PROCESS {

   $properties1 = $FirstCollection[0] | gm -type Properties | Select -Expand Name
   $properties2 = $SecondCollection[0] | gm -type Properties | Where { $Properties1 -notcontains $_.Name } | Select -Expand Name

   foreach($first in $FirstCollection) {
      foreach($second in $SecondCollection | Where{ $_."$SecondJoinColumn" -eq $first."$FirstJoinColumn" } ) {
        [string]$join = $first | gm -type Properties | select -expand Definition | %{($_ -split " ",2)[1]}
        $join += "`n"
        $join += $second | gm -Name $Properties2 -type Properties | select -expand Definition | %{($_ -split " ",2)[1]}
        ConvertFrom-StringData $join | ConvertFrom-Hashtable
      }
   }
}
#}
