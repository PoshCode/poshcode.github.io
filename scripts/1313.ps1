# vProfile-ClusterAudit.ps1	: vSphere cluster node auditing script
# This script will compare all VI/vSphere cluster nodes against a reference node
# Parameters:
#	$xmlFile	: XML profile file, created by the vProfile.ps1 script
#	$csvFile	: CSV file that will conatin the discovered differences
#	$referenceHost	: hostname of the node that will the "reference" node
# Author:	LucD
# History:
#	v1.0 27/08/09	first version
#

# Parameters
$xmlFile = "C:\vInventoryCluster-Clus1.xml"
$csvFile = "C:\Clus1-diff.csv"
$referenceHost = "esx41.test.local"


$global:report = @()

function Compare-Attributes{
	param($ref, $node, $path, $origrow)

	$refFirstAttrib = $ref.MoveToFirstAttribute()
	$nodeFirstAttrib = $node.MoveToFirstAttribute()
	if($refFirstAttrib -and $nodeFirstAttrib){
		do {
			if($node.Value -ne $ref.Value){
				$line = $origrow
				$line.Name = $ref.LocalName
				$line.RefValue = $ref.Value
				$line.CmpValue = $node.Value
				$global:report += $line
			}
			$refNextAttrib = $ref.MoveToNextAttribute()
			$nodeNextAttrib = $node.MoveToNextAttribute()
		} while ($refNextAttrib -and $nodeNextAttrib)

		$dummy = $ref.MoveToParent()
		$dummy = $node.MoveToParent() 
	}
}

function Compare-Recursive{ 
	param($ref, $nav, $path) 

	$path += ("/" + $nav.LocalName)
	
	$report = @()
	$row = New-Object PsObject
	$row | Add-Member -MemberType NoteProperty -Name Path -Value "na"
	$row | Add-Member -MemberType NoteProperty -Name RefHost -Value "na"
	$row | Add-Member -MemberType NoteProperty -Name CmpHost -Value "na"
	$row | Add-Member -MemberType NoteProperty -Name Name -Value "na"
	$row | Add-Member -MemberType NoteProperty -Name RefValue -Value "na"
	$row | Add-Member -MemberType NoteProperty -Name CmpValue -Value "na"
	$row | Add-Member -MemberType NoteProperty -Name AttributeDiscrepancy -Value $false
	$row | Add-Member -MemberType NoteProperty -Name ChildrenDiscrepancy -Value $false

	$row.Path = $path
	$row.RefHost = $refHost.Name
	$row.CmpHost = $selHost.Name
	if($nav.HasAttributes -and $ref.HasAttributes){
		Compare-Attributes $ref $nav $path $row
	}
	elseif($nav.HasAttributes -ne $ref.HasAttributes){
		$row.AttributeDiscrepancy = $true
	}

	if($nav.HasChildren -and $ref.HasChildren){
		$refFirstChild = $ref.MoveToFirstChild()
		$navFirstChild = $nav.MoveToFirstChild()
		if($refFirstChild -and $navFirstChild){ 
			do { 
				Compare-Recursive $ref $nav $path
				$refNextChild = $ref.MoveToNext()
				$navNextChild = $nav.MoveToNext()
			} while ($refNextChild -and $navNextChild) 

			$dummy = $ref.MoveToParent()
			$dummy = $nav.MoveToParent()
		}
	}
	elseif($nav.HasChildren -ne $ref.HasChildren){
		$row.ChildrenDiscrepancy = $true
	}
} 

$path = "Inventory/Cluster"

$xml = [xml](Get-Content $xmlFile) 

$refPath = "Inventory/Cluster/Host[@Name='" + $referenceHost + "']"
$otherPath = "Inventory/Cluster/Host[@Name!='" + $referenceHost + "']"

$refHost = $xml.SelectSingleNode($refPath)
$refNav = $refHost.PSBase.CreateNavigator()

foreach($selHost in $xml.SelectNodes($otherPath)){
	$refCopy = $refNav
	$navigator = $selHost.PSBase.CreateNavigator()
	$result += (Compare-Recursive $refCopy $navigator $path)
} 
$global:report | Export-Csv $csvFile  -NoTypeInformation

