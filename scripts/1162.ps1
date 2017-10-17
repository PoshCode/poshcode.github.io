##
# Remove-MyOldComputers.ps1
#
#  Makes certian assumptions about your computers naming scheme: mainly that all your
#  computers are named as follows: {username}* I.E. bob1, bob-test, bob-server, etc
#
##
param (
  [String] $Name=((whoami).Split('\')[1]),
  [Int32] $MaxDaysOld=20
)


$root = [ADSI]''
$searcher = new-object System.DirectoryServices.DirectorySearcher($root)
$searcher.filter = "(Name=$Name*)"
$computers = $searcher.findall()
$computers | % {
  $Comp = [ADSI]$_.Path  
  $LastChange = [DateTime]::Now - [DateTime][String]$Comp.WhenChanged
  if ($LastChange.TotalDays -gt $MaxDaysOld) {
    Write-Host Deleting $Comp.Name [$LastChangeTimeSpan.TotalDays days old]
    $Comp.psbase.DeleteTree()
  }
}
