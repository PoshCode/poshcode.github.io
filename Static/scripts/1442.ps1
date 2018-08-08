Function Get-DriveInfo([string]$computer = "localhost") {
  PROCESS{
    $LogicalDrive = Get-WmiObject –computername $computer Win32_LogicalDisk -filter "DriveType=3"
    $PhysicalDrive = Get-WmiObject -class "Win32_DiskDrive" -namespace "root\CIMV2" -computername $computer
	
	$objResult = @()
	
	foreach ($item in $LogicalDrive) {
      $Logical = New-Object System.Object
      $logical | Add-Member -MemberType NoteProperty -Name ServerName -value $computer
      $Logical | Add-Member -MemberType NoteProperty -Name LogicalDeviceID -value $item.deviceid
      $Logical | Add-Member -MemberType NoteProperty -Name LogicalDiskSizeGB -value ($item.size/1GB).tostring("0.00")
      $Logical | Add-Member -MemberType NoteProperty -Name LogicalFreeSpaceGB -value ($item.freeSpace/1GB).tostring("0.00")
      $Logical | Add-Member -MemberType NoteProperty -Name LogicalUsedSpaceGB -value (($item.size/1GB)-($item.freeSpace/1GB)).tostring("0.00")
      
      $objResult += $Logical
    }
	
	foreach ($item in $PhysicalDrive ) {
      $physical = New-Object System.Object
      $physical | Add-Member -MemberType NoteProperty -Name ServerName -value $computer
      $physical | Add-Member -MemberType NoteProperty -Name PhysicalCaption -value $item.Caption
      $physical | Add-Member -MemberType NoteProperty -Name PhysicalSizeGB -value ($item.size/1GB).tostring("0.00")
      $physical | Add-Member -MemberType NoteProperty -Name Manufacturer -value $item.Manufacturer
      
      $objResult += $physical
    }
	
	Write-Output $objResult
        
    }
}
