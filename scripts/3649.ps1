<#
.SYNOPSIS
    Report-RecipientCounts.ps1
    Keep a running total of daily recipient count distribution.

.DESCRIPTION
    Keep a running total of daily recipient count distribution.
    
.PARAMETER Days
    The number of days back to examine logs. 
    Default = 1 (Yesterday)
    
.EXAMPLE
    Report-RecipientCounts.ps1
    
    Get the report for yesterday.
    
.EXAMPLE
    Report-RecipientCounts.ps1 -Days 3
    
    Get the report for 3 days ago, which was missed

.NOTES
    Original framework for this report came from:
    http://www.msexchange.org/kbase/ExchangeServerTips/ExchangeServer2010/Monitoring/E-mailRecipientNumberDistribution.html

    I modified the script slightly so we can have a running history and a quick view web page.
    
#>

param(
       [int]$Days= 1
)
 
# set the time period for the report - default is yesterday
$Days = $Days * (-1)
$Start = get-date $((get-date).adddays($Days)) -hour 00 -minute 00 -second 00
$End   = get-date $((get-date).adddays($Days)) -hour 23 -minute 59 -second 59

#=====> TO DO  -- change <webserver> to a location in your environment
$HistoryFile = '\\<webserver>\RecipientCounts.CSV'
$HTMLOutFile = '\\<webserver>\RecipientCounts.htm'

 
$RecipientCounts = @()
If (Test-Path$HistoryFile){$RecipientCounts = Import-Csv $HistoryFile}
 
# Create a new object to hold today's finding
$NewCountObj = New-ObjectPSObject
$NewCountObj | Add-Member -typeNoteProperty-name Date      -value (get-date $Start -Format yyyyMMdd)
$NewCountObj | Add-Member -typeNoteProperty-name '1'       -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '2'       -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '5'       -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '10'      -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '30'      -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '50'      -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '75'      -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '100'     -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '150'     -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '200'     -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '250'     -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '300'     -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '350'     -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '400'     -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '500'     -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '600'     -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '700'     -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '800'     -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '900'     -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '1000'    -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '3000'    -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name '5000'    -value (0)
$NewCountObj | Add-Member -typeNoteProperty-name 'Big'     -value (0)
 
 

Get-TransportServer | Get-MessageTrackingLog -ResultSize Unlimited -EventID RECEIVE -Start $Start -End $End |
    ? {$_.Source -eq "STOREDRIVER"} |
    Select RecipientCount |
    ForEach {
	    If ($_.RecipientCount-eq 1) {$NewCountObj.'1'++ }
	    If ($_.RecipientCount-eq 2) {$NewCountObj.'2'++ }
	    If ($_.RecipientCount-gt 2    -and $_.RecipientCount -le 5)    {$NewCountObj.'5'++ }
	    If ($_.RecipientCount-gt 5    -and $_.RecipientCount -le 10)   {$NewCountObj.'10'++ }
	    If ($_.RecipientCount-gt 10   -and $_.RecipientCount -le 30)   {$NewCountObj.'30'++ }
	    If ($_.RecipientCount-gt 30   -and $_.RecipientCount -le 50)   {$NewCountObj.'50'++ }
	    If ($_.RecipientCount-gt 50   -and $_.RecipientCount -le 75)   {$NewCountObj.'75'++ }
	    If ($_.RecipientCount-gt 75   -and $_.RecipientCount -le 100)  {$NewCountObj.'100'++ }
	    If ($_.RecipientCount-gt 100  -and $_.RecipientCount -le 150)  {$NewCountObj.'150'++ }
	    If ($_.RecipientCount-gt 150  -and $_.RecipientCount -le 200)  {$NewCountObj.'200'++ }
	    If ($_.RecipientCount-gt 200  -and $_.RecipientCount -le 250)  {$NewCountObj.'250'++ }
	    If ($_.RecipientCount-gt 250  -and $_.RecipientCount -le 300)  {$NewCountObj.'300'++ }
	    If ($_.RecipientCount-gt 300  -and $_.RecipientCount -le 350)  {$NewCountObj.'350'++ }
	    If ($_.RecipientCount-gt 350  -and $_.RecipientCount -le 400)  {$NewCountObj.'400'++ }
	    If ($_.RecipientCount-gt 400  -and $_.RecipientCount -le 500)  {$NewCountObj.'500'++ }
	    If ($_.RecipientCount-gt 500  -and $_.RecipientCount -le 600)  {$NewCountObj.'600'++ }
	    If ($_.RecipientCount-gt 600  -and $_.RecipientCount -le 700)  {$NewCountObj.'700'++ }
	    If ($_.RecipientCount-gt 700  -and $_.RecipientCount -le 800)  {$NewCountObj.'800'++ }
	    If ($_.RecipientCount-gt 800  -and $_.RecipientCount -le 900)  {$NewCountObj.'900'++ }
	    If ($_.RecipientCount-gt 900  -and $_.RecipientCount -le 1000) {$NewCountObj.'1000'++ }
	    If ($_.RecipientCount-gt 1000 -and $_.RecipientCount -le 3000) {$NewCountObj.'3000'++ }
	    If ($_.RecipientCount-gt 3000 -and $_.RecipientCount -le 5000) {$NewCountObj.'5000'++ }
	    If ($_.RecipientCount-gt 5000) {$NewCountObj.Big++ }
	}	
 
$NewCounts= @()
if ($RecipientCounts) {
      $NewCounts = @($RecipientCounts) + @($NewCountObj)
}Else {
      $NewCounts = $NewCountObj
}
$NewCounts=$NewCounts | Sort Date-Descending
$NewCounts | Export-Csv $HistoryFile -NoTypeInformation
 
# Simple Headers
$Header1 = '<h2><font Color = #151b8d><p style="text-align: center;"><b>Recipient Counts History Report</b></p></font></h2>'
$Header2 = '<h4><font Color = #151b8d><p style="text-align: center;"><b>(Updated Daily via[' + $(split-path $MyInvocation.InvocationName -Leaf) + '])</b></p></Font></h4>'
$Header3 = '<h3><font Color = #800517><p style="text-align: center;">' + $(Get-Date) + '</font></H3></p>'
$a = "<style>"
$a = $a + "BODY{background-color:LightCyan;text-align: center;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;text-align: center;}"
$a = $a + "TH{border-width: 1px;padding: 1px;border-style: solid;border-color: black;background-color:Bisque}"
$a = $a + "TD{border-width: 1px;padding: 1px;border-style: solid;border-color: black;background-color:AntiqueWhite}"
$a = $a + "</style>"

$NewCounts | ConvertTo-Html -Head ($A,$Header1,$Header2,$Header3) | out-file $HTMLOutFile -Force

