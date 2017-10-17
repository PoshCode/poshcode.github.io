# Name   : smsDiagram.ps1
# Author : David "Makovec" Moravec
# Web    : http://www.powershell.cz
# Email  : powershell.cz@googlemail.com
# Twitter: makovec
#
# Description: Draw SMS 2003 hierarchy in Visio
#
# Version: 1.0
# History:
#  v0.1 - (add) Alan's vDiagram functions
#         (add) WMI query
#  v0.2 - (add) -server parameter
#         (add) -textInfo parameter
#         (add) Primary/Secondary 
#  v0.3 - (add) Visio drawing
#         (add) -debug parameter
#  v0.4 - (change) working with $x, $y to fine tune shapes
#         (add) save final Visio file
#  v1.0 - (changed) script renamed to smsDiagram
# 
# Usage: smsDiagram.ps1 -server czsms01
#          - Draw SMS hierarchy in Visio
#        smsDiagram.ps1 -server czsms01 -textInfo
#          - Print SMS hierarchy to console
#
#################################################################

param (
	$server = $(throw "You must enter server name."),
	[switch]$debug,
	[switch]$textInfo
)

# $debug set - enable messages
if ($debug) {
	$DebugPreference = "Continue"
	Write-Debug "Debugging enabled."
}

###############################################################################
########################################################## FUNCTIONS DEFINITION
###############################################################################

#                                                      Function Add-VisioObject
###############################################################################
function Add-VisioObject ($mastObj, $item) {
 	Write-Debug "fnc(Add-VisioObject) $($item.SiteCode) - $($item.ServerName)"
	Write-Host "Adding $($item.SiteCode) - $($item.ServerName)"
	
	# Drop the selected stencil on the active page, with the coordinates x, y
  	$shpObj = $pagObj.Drop($mastObj, $script:x, $script:y)
	
	# Enter text for the object
  	$shpObj.Characters.Text = $item.SiteCode
	
	#Return the visioobject to be used
	return $shpObj
 } # function Add-VisioObject

#                                                  Function Connect-VisioObject
###############################################################################
function Connect-VisioObject ($firstObj, $secondObj)
{
	$shpConn = $pagObj.Drop($pagObj.Application.ConnectorToolDataObject, 0, 0)

	# Connect its Begin to the 'From' shape:
	$connectBegin = $shpConn.CellsU("BeginX").GlueTo($firstObj.CellsU("PinX"))
	
	# Connect its End to the 'To' shape:
	$connectEnd = $shpConn.CellsU("EndX").GlueTo($secondObj.CellsU("PinX"))
		
} # function Connect-VisioObject

#                                                  Function Print-TextHierarchy
###############################################################################
function Print-TextHierarchy {
param (
	$inputSrv,
	$level
)

$downLevelSites = $servers |? {$_.ReportingSiteCode -eq $inputSrv.SiteCode}
$level += 1
$space = " "*$level*2

if ($downLevelSites -ne $null) {	
	foreach ($i in $downLevelSites) {
		Write-Host $space -NoNewLine
		if ($i.Type -eq 2) {
			$text = "$($i.SiteCode) (P)"
		}
		else {
			$text = "$($i.SiteCode)"
		}
		
		Write-Host $text
		Print-TextHierarchy $i $level
	} # foreach $downLevelSites
}
else {
	# empty block
} # else
} # function Print-TextHierarchy

#                                                  Function Draw-VisioHierarchy
###############################################################################
function Draw-VisioHierarchy {
param (
	$VSobjParent,
	$inputSrv
)

# Type of server (primary/secondary)
if ($inputSrv.Type -eq 2) {
	# Primary server
	$DrawObj = $PrimaryObj
}
else {
	# Secondary server
	$DrawObj = $SecondaryObj
}		

$VSobjCurr = Add-VisioObject $DrawObj $inputSrv

if ($VSobjParent -ne $null) {
	Connect-VisioObject $VSobjParent $VSobjCurr
}

$downLevelSites = $servers |? {$_.ReportingSiteCode -eq $inputSrv.SiteCode}

if ($downLevelSites -ne $null) {
	$script:y -= 1.5
	foreach ($i in $downLevelSites) {
		$script:x += 1
		Draw-VisioHierarchy $VSobjCurr $i
	} # foreach $downLevelSites
	$script:x -= 1
}
else {
	# Move secondary servers x-axis tam
	$script:x += 1	
	$script:y += 1.5	
} # else
$script:y -= 1.5
if ($inputSrv.Type -eq 2) {
	$script:x -= ($offset*$downLevelSites.Count)-1
}
$script:x -= $offset
} # function Draw-VisioHierarchy

###############################################################################
########################################################################## MAIN
###############################################################################

#                                                            Load info from WMI
###############################################################################

# Site code
$siteCode = (Get-WmiObject -ComputerName $server -Namespace root/sms `
	-Class SMS_ProviderLocation -Filter "ProviderForLocalSite='True'").SiteCode
# SMS Namespace path
$SMSWMINamespace = 'root/sms/site_'+$siteCode

# List of children servers from SMS_Site class
$servers = Get-WmiObject -ComputerName $server -Namespace $SMSWMINamespace -Class SMS_Site | `
	Select ReportingSiteCode, SiteCode, ServerName, Type | `
	Sort ReportingSiteCode, SiteCode

# For testing at home use exported objects
#$servers = Import-Clixml ./SMSsvr_t.xml | Sort ReportingSiteCode, SiteCode

# Set central server as object
$centralSMSServer = $servers[0]

# Do you want text representation to the console ?
if ($textInfo) {
	Write-Host "$($centralSMSServer.SiteCode) (P)"
	Print-TextHierarchy $centralSMSServer 0
	return
}

#                                                         Prepare Visio objects
###############################################################################

# Create an instance of Visio and create an empty document 
$AppVisio = New-Object -ComObject Visio.Application
$docsObj = $AppVisio.Documents
$DocObj = $docsObj.Add("Detailed Network Diagram.vst")

# Set the active page
$pagsObj = $AppVisio.ActiveDocument.Pages
$pagObj = $pagsObj.Item(1)

# Select stencils to drop
$stnObj = $AppVisio.Documents.Item("SERVER_M.VSS")

# Set server types shapes
$PrimaryObj = $stnObj.Masters.Item("Database Server")
$SecondaryObj =  $stnObj.Masters.Item("Server")

# Set coordinates for first object
$script:x = 1
$script:y = 8
$offset = 1

Draw-VisioHierarchy $null $centralSMSServer 

# Resize to fit page
$pagObj.ResizeToFitContents()

$SaveFile = [system.Environment]::GetFolderPath('MyDocuments') + "\My_smsDiagram.vsd"
$DocObj.SaveAs($SaveFile) | Out-Null
Write-Output "Document saved as $SaveFile"
