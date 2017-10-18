Function get-sandisks ([string]$InputFilename,[string]$OutputFilename)
{
$strComputer = gc $InputFilename
$MyObj = @()
foreach ($server in $strComputer) {
$colItems = get-wmiobject -class "Win32_DiskDrive" -namespace "root\CIMV2" -computername $server
foreach ($objItem in $colItems) { 
$Rep = "" | select "Server Name", "Disk", "Disk Space", "Type"
      $Rep."Disk" = $objItem.DeviceID 
      $Rep."Type" = $objItem.Model 
      $Rep."Disk Space" = ([Math]::Round($objItem.Size/1gb, 2)) 
      $Rep."Server Name" = $objItem.SystemName 
      $MyObj += $Rep
      #$MyObj
      $rep = $null}
      }
 $MyObj | sort | Export-Csv -Path $OutputFilename -NoTypeInformation
}
