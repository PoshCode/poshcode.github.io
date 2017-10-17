﻿###########################################################################"
#
# NAME: Get-ADGroupModificationsReport.ps1
#
# AUTHOR: Jan Egil Ring
# EMAIL: jan.egil.ring@powershell.no
#
# COMMENT: Generates a HTML-report of Active Directory group membership modifications (addings and deletions). 
#          Specify a valid path on line 211 to store the report.
#          For more details, see the following blog-post: 
#          http://janegilring.wordpress.com/2009/10/11/active-directory-group-membership-modifications-report
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the creator, owner above has no warranty, obligations,
# or liability for such use.
#
# VERSION HISTORY:
# 1.0 11.10.2009 - Initial release
#
###########################################################################"

#Requires -Version 2.0


Function Get-CustomHTML ($Header){
$Report = @"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http`://www.w3.org/TR/html4/frameset.dtd">
<html><head><title>$($Header)</title>
<META http-equiv=Content-Type content='text/html; charset=windows-1252'>

<meta name="save" content="history">

<style type="text/css">
DIV .expando {DISPLAY: block; FONT-WEIGHT: normal; FONT-SIZE: 10pt; RIGHT: 8px; COLOR: #ffffff; FONT-FAMILY: Tahoma; POSITION: absolute; TEXT-DECORATION: underline}
TABLE {TABLE-LAYOUT: fixed; FONT-SIZE: 100%; WIDTH: 100%}
*{margin:0}
.dspcont { BORDER-RIGHT: #bbbbbb 1px solid; BORDER-TOP: #bbbbbb 1px solid; PADDING-LEFT: 16px; FONT-SIZE: 8pt;MARGIN-BOTTOM: -1px; PADDING-BOTTOM: 5px; MARGIN-LEFT: 0px; BORDER-LEFT: #bbbbbb 1px solid; WIDTH: 95%; COLOR: #000000; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: #bbbbbb 1px solid; FONT-FAMILY: Tahoma; POSITION: relative; BACKGROUND-COLOR: #f9f9f9}
.filler {BORDER-RIGHT: medium none; BORDER-TOP: medium none; DISPLAY: block; BACKGROUND: none transparent scroll repeat 0% 0%; MARGIN-BOTTOM: -1px; FONT: 100%/8px Tahoma; MARGIN-LEFT: 43px; BORDER-LEFT: medium none; COLOR: #ffffff; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: medium none; POSITION: relative}
.save{behavior:url(#default#savehistory);}
.dspcont1{ display:none}
a.dsphead0 {BORDER-RIGHT: #bbbbbb 1px solid; PADDING-RIGHT: 5em; BORDER-TOP: #bbbbbb 1px solid; DISPLAY: block; PADDING-LEFT: 5px; FONT-WEIGHT: bold; FONT-SIZE: 8pt; MARGIN-BOTTOM: -1px; MARGIN-LEFT: 0px; BORDER-LEFT: #bbbbbb 1px solid; CURSOR: hand; COLOR: #FFFFFF; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: #bbbbbb 1px solid; FONT-FAMILY: Tahoma; POSITION: relative; HEIGHT: 2.25em; WIDTH: 95%; BACKGROUND-COLOR: #cc0000}
a.dsphead1 {BORDER-RIGHT: #bbbbbb 1px solid; PADDING-RIGHT: 5em; BORDER-TOP: #bbbbbb 1px solid; DISPLAY: block; PADDING-LEFT: 5px; FONT-WEIGHT: bold; FONT-SIZE: 8pt; MARGIN-BOTTOM: -1px; MARGIN-LEFT: 0px; BORDER-LEFT: #bbbbbb 1px solid; CURSOR: hand; COLOR: #ffffff; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: #bbbbbb 1px solid; FONT-FAMILY: Tahoma; POSITION: relative; HEIGHT: 2.25em; WIDTH: 95%; BACKGROUND-COLOR: #7BA7C7}
a.dsphead2 {BORDER-RIGHT: #bbbbbb 1px solid; PADDING-RIGHT: 5em; BORDER-TOP: #bbbbbb 1px solid; DISPLAY: block; PADDING-LEFT: 5px; FONT-WEIGHT: bold; FONT-SIZE: 8pt; MARGIN-BOTTOM: -1px; MARGIN-LEFT: 0px; BORDER-LEFT: #bbbbbb 1px solid; CURSOR: hand; COLOR: #ffffff; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: #bbbbbb 1px solid; FONT-FAMILY: Tahoma; POSITION: relative; HEIGHT: 2.25em; WIDTH: 95%; BACKGROUND-COLOR: #A5A5A5}
a.dsphead1 span.dspchar{font-family:monospace;font-weight:normal;}
td {VERTICAL-ALIGN: TOP; FONT-FAMILY: Tahoma}
th {VERTICAL-ALIGN: TOP; COLOR: #cc0000; TEXT-ALIGN: left}
BODY {margin-left: 4pt} 
BODY {margin-right: 4pt} 
BODY {margin-top: 6pt} 
</style>
</head>
<body>
<b><font face="Arial" size="5">$($Header)</font></b><hr size="8" color="#cc0000">
<font face="Arial" size="1"><b>Generated on $($ENV:Computername)</b></font><br>
<font face="Arial" size="1">Report created on $(Get-Date)</font>
<div class="filler"></div>
<div class="filler"></div>
<div class="filler"></div>
<div class="save">
"@
Return $Report
}

Function Get-CustomHeader0 ($Title){
$Report = @"
		<h1><a class="dsphead0">$($Title)</a></h1>
	<div class="filler"></div>
"@
Return $Report
}

Function Get-CustomHeader ($Num, $Title){
$Report = @"
	<h2><a class="dsphead$($Num)">
	$($Title)</a></h2>
	<div class="dspcont">
"@
Return $Report
}

Function Get-CustomHeaderClose{

	$Report = @"
		</DIV>
		<div class="filler"></div>
"@
Return $Report
}

Function Get-CustomHeader0Close{

	$Report = @"
</DIV>
"@
Return $Report
}

Function Get-CustomHTMLClose{

	$Report = @"
</div>

</body>
</html>
"@
Return $Report
}

Function Get-HTMLTable {
	param([array]$Content)
	$HTMLTable = $Content | ConvertTo-Html
	$HTMLTable = $HTMLTable -replace "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN""  ""http`://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">", ""
	$HTMLTable = $HTMLTable -replace "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01//EN""  ""http`://www.w3.org/TR/html4/strict.dtd"">", ""
	$HTMLTable = $HTMLTable -replace "<html xmlns=""http`://www.w3.org/1999/xhtml"">", ""
	$HTMLTable = $HTMLTable -replace '<html>', ""
	$HTMLTable = $HTMLTable -replace '<head>', ""
	$HTMLTable = $HTMLTable -replace '<title>HTML TABLE</title>', ""
	$HTMLTable = $HTMLTable -replace '</head><body>', ""
	$HTMLTable = $HTMLTable -replace '</body></html>', ""
	Return $HTMLTable
}

Function Get-HTMLDetail ($Heading, $Detail){
$Report = @"
<TABLE>
	<tr>
	<th width='25%'><b>$Heading</b></font></th>
	<td width='75%'>$($Detail)</td>
	</tr>
</TABLE>
"@
Return $Report
}

function isWithin([int]$days, [datetime]$Date)
{
    [DateTime]::Now.AddDays($days).Date -le $Date.Date
}

#Initialize array for domain controllers in the current domain
$domaincontrollers = @()

#Get current domain
$dom = [System.DirectoryServices.ActiveDirectory.Domain]::getcurrentdomain()

#Get domain controllers in the current domain and add them to the $domain controllers array
$dom.DomainControllers | select Name | ForEach-Object {$domaincontrollers += $_.name}



$MyReport = Get-CustomHTML "Active Directory Group Modifications - Daily Report"
	$MyReport += Get-CustomHeader0 ("$domaincontroller")
		
		# ---- General Summary Info ----
		$MyReport += Get-CustomHeader "1" "General Details"
			$MyReport += Get-HTMLDetail "Domain name:" $dom
			$MyReport += Get-HTMLDetail "Number of Domain Controllers:" $domaincontrollers.count
		$MyReport += Get-CustomHeaderClose

foreach ($domaincontroller in $domaincontrollers){
# ---- Members added to Domain Local Groups ----
                $MyReport += Get-CustomHeader "1" "Members added to Domain Local Groups on domaincontroller $domaincontroller"
                        $MyReport += Get-HTMLTable (Get-EventLog -LogName 'Security' -ComputerName $domaincontroller | Where-Object {(isWithin -1 $_.TimeWritten) -and $_.EventID -eq "636" -or $_.EventID -eq "4732"} | select TimeGenerated,Message  )
                $MyReport += Get-CustomHeaderClose

$MyReport += Get-CustomHeader0Close
$MyReport += Get-CustomHTMLClose

# ---- Members removed from Domain Local Groups ----
                $MyReport += Get-CustomHeader "1" "Members removed from Domain Local Groups on domaincontroller $domaincontroller"
                        $MyReport += Get-HTMLTable (Get-EventLog -LogName 'Security' -ComputerName $domaincontroller | Where-Object {(isWithin -1 $_.TimeWritten) -and $_.EventID -eq "637" -or $_.EventID -eq "4733"} | select TimeGenerated,Message  )
                $MyReport += Get-CustomHeaderClose

$MyReport += Get-CustomHeader0Close
$MyReport += Get-CustomHTMLClose

# ---- Members added to Global Groups ----
                $MyReport += Get-CustomHeader "1" "Members added to Global Groups on domaincontroller $domaincontroller"
                        $MyReport += Get-HTMLTable (Get-EventLog -LogName 'Security' -ComputerName $domaincontroller | Where-Object {(isWithin -1 $_.TimeWritten) -and $_.EventID -eq "632" -or $_.EventID -eq "4728"} | select TimeGenerated,Message  )
                $MyReport += Get-CustomHeaderClose

$MyReport += Get-CustomHeader0Close
$MyReport += Get-CustomHTMLClose

# ---- Members removed from Global Groups ----
                $MyReport += Get-CustomHeader "1" "Members removed from Global Groups on domaincontroller $domaincontroller"
                        $MyReport += Get-HTMLTable (Get-EventLog -LogName 'Security' -ComputerName $domaincontroller | Where-Object {(isWithin -1 $_.TimeWritten) -and $_.EventID -eq "633" -or $_.EventID -eq "4729"} | select TimeGenerated,Message  )
                $MyReport += Get-CustomHeaderClose

$MyReport += Get-CustomHeader0Close
$MyReport += Get-CustomHTMLClose

# ---- Members added to Universal Groups ----
                $MyReport += Get-CustomHeader "1" "Members added to Universal Groups on domaincontroller $domaincontroller"
                        $MyReport += Get-HTMLTable (Get-EventLog -LogName 'Security' -ComputerName $domaincontroller | Where-Object {(isWithin -1 $_.TimeWritten) -and $_.EventID -eq "660" -or $_.EventID -eq "4756"} | select TimeGenerated,Message  )
                $MyReport += Get-CustomHeaderClose

$MyReport += Get-CustomHeader0Close
$MyReport += Get-CustomHTMLClose

# ---- Members removed from Universal Groups ----
                $MyReport += Get-CustomHeader "1" "Members removed from Universal Groups on domaincontroller $domaincontroller"
                        $MyReport += Get-HTMLTable (Get-EventLog -LogName 'Security' -ComputerName $domaincontroller | Where-Object {(isWithin -1 $_.TimeWritten) -and $_.EventID -eq "661" -or $_.EventID -eq "4757"} | select TimeGenerated,Message  )
                $MyReport += Get-CustomHeaderClose

$MyReport += Get-CustomHeader0Close
$MyReport += Get-CustomHTMLClose

}

$Date = Get-Date
$Filename = "C:\Temp\" + "DailyReport" + "_" + $Date.Day + "-" + $Date.Month + "-" + $Date.Year + ".htm"
$MyReport | out-file -encoding ASCII -filepath $Filename
