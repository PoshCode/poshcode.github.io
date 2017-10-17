############################################################################
#
#	Collect.ps1
#	Version: 0.2
#	Script to Collect Information from PCs in a Subnet 
#	By: 	Brad Blaylock
#	For: 	St. Bernards RMC
#	Date:	3-25-2010
#
############################################################################


############################################################################
#  Collect.ps1 Script --  Output to OpenOffice Calc                    
############################################################################
#
#
#___________________________________________________________________________
############################################################################
#__________________CREATE OPEN OFFICE CALC SHEET____________________________
[System.Reflection.Assembly]::LoadWithPartialName('cli_basetypes') 
[System.Reflection.Assembly]::LoadWithPartialName('cli_cppuhelper') 
[System.Reflection.Assembly]::LoadWithPartialName('cli_oootypes') 
[System.Reflection.Assembly]::LoadWithPartialName('cli_ure') 
[System.Reflection.Assembly]::LoadWithPartialName('cli_uretypes') 
$localContext = [uno.util.Bootstrap]::bootstrap() 
$multiComponentFactory = [unoidl.com.sun.star.uno.XComponentContext].getMethod('getServiceManager').invoke($localContext, @()) 
$desktop = [unoidl.com.sun.star.lang.XMultiComponentFactory].getMethod('createInstanceWithContext').invoke($multiComponentFactory, @('com.sun.star.frame.Desktop', $localContext)) 
$calc = [unoidl.com.sun.star.frame.XComponentLoader].getMethod('loadComponentFromURL').invoke($desktop, @('private:factory/scalc', '_blank', 0, $null)) 
$sheets = [unoidl.com.sun.star.sheet.XSpreadsheetDocument].getMethod('getSheets').invoke($calc, @()) 
$sheet = [unoidl.com.sun.star.container.XIndexAccess].getMethod('getByIndex').invoke($sheets, @(0)) 
#Cell definitions - Header Row
$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(0,0)) 
[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @('IP Address')) 
$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(1,0)) 
[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @('Hostname')) 
$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(2,0)) 
[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @('Serial')) 
$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(3,0)) 
[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @('OS')) 
$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(4,0)) 
[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @('SvcPk')) 
$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(5,0)) 
[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @('CPU')) 
$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(6,0)) 
[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @('RAM')) 
$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(7,0)) 
[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @('C: Size')) 
$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(8,0)) 
[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @('C: Free')) 
$i=1			#Establish variable for Row Imcrementation.
#___________________________END OPEN OFFICE DEFINE____________________________


						#Establish Ping Object
$ping = new-object System.Net.NetworkInformation.Ping;
						#Encorporate Error handling
ri $env:temp\*.txt -r -v –ea 0


#________________________________________________________________________________
#                        BEGIN GUI INTERFACE
#________________________________________________________________________________


[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Collect.ps1"
$objForm.Size = New-Object System.Drawing.Size(200,300) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$subnet=$objTextBoxsub.Text;[int]$start=$objTextBoxstart.Text;$end=$objTextBoxend.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(15,220)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$subnet=$objTextBoxsub.Text;[int]$start=$objTextBoxstart.Text;$end=$objTextBoxend.Text;$objForm.Close()})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(105,220)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabelsub = New-Object System.Windows.Forms.Label
$objLabelsub.Location = New-Object System.Drawing.Size(10,20) 
$objLabelsub.Size = New-Object System.Drawing.Size(150,20) 
$objLabelsub.Text = "Enter Subnet (1st 3 octets):"
$objForm.Controls.Add($objLabelsub) 

$objTextBoxsub = New-Object System.Windows.Forms.TextBox 
$objTextBoxsub.Location = New-Object System.Drawing.Size(10,40) 
$objTextBoxsub.Size = New-Object System.Drawing.Size(160,20)
$objForm.Controls.Add($objTextBoxsub) 

$objLabelstart = New-Object System.Windows.Forms.Label
$objLabelstart.Location = New-Object System.Drawing.Size(10,70) 
$objLabelstart.Size = New-Object System.Drawing.Size(150,20) 
$objLabelstart.Text = "Enter beginning node below:"
$objForm.Controls.Add($objLabelstart) 

$objTextBoxstart = New-Object System.Windows.Forms.TextBox 
$objTextBoxstart.Location = New-Object System.Drawing.Size(10,90) 
$objTextBoxstart.Size = New-Object System.Drawing.Size(160,20) 
$objForm.Controls.Add($objTextBoxstart) 

$objLabelend = New-Object System.Windows.Forms.Label
$objLabelend.Location = New-Object System.Drawing.Size(10,120) 
$objLabelend.Size = New-Object System.Drawing.Size(150,20) 
$objLabelend.Text = "Enter ending node below:"
$objForm.Controls.Add($objLabelend) 

$objTextBoxend = New-Object System.Windows.Forms.TextBox 
$objTextBoxend.Location = New-Object System.Drawing.Size(10,140) 
$objTextBoxend.Size = New-Object System.Drawing.Size(160,20) 
$objForm.Controls.Add($objTextBoxend) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate();$objTextBoxsub.Focus()})
[Void] $objForm.ShowDialog()
$objForm.Dispose()

#________________________________________________________________________
#							END GUI INTERFACE
#________________________________________________________________________

						#Main Script Section
while ($start -le $end)
{ 
		#----------------==Subnet Arguments==----------------------
		$strAddress = "$subnet.$start"
		#***
		#***
		#_____________________________________________________________
		$start++
		$stat=$ping.Send($strAddress).status;
        if($stat -ne "Success")
		{
		#If Host is NOT online Exit here with message of unavailability.
		write-warning "$strAddress is not available <$stat>";
		Write-Host
		Write-Host
		} 
        else 
		#Collect Desired Data from Live IP Addresses.
		{
			#Write IP Address to OpenOffice Calc
			$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(0,$i)) 
			[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @($strAddress)) 
			
			#Set $strComputer variable to Hostname.
			$ErrorActionPreference = "SilentlyContinue"
			$strComputer = [System.Net.Dns]::GetHostByAddress($strAddress).HostName | Foreach-Object {$_ -replace ".ma.dl.cox.net", ""} 
			$ErrorActionPreference = "Continue"
			
			#Get Computer Name
			$ErrorActionPreference = "SilentlyContinue"
    		$colPCName = get-wmiobject -class "Win32_BIOS" -namespace "root\CIMV2" `
    		-computername $strComputer 
			$ErrorActionPreference = "Continue"


   			foreach ($objItem in $colPCName)
   			{
    			#Write Computer Name to OpenOffice Calc
				$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(1,$i)) 
				[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @($strComputer)) 
   			}
			
			#Get System Serial Number from BIOS.
			$ErrorActionPreference = "SilentlyContinue"
   			$colItems = get-wmiobject -class “Win32_BIOS” -computername $strComputer 
			$ErrorActionPreference = "Continue"
			
			foreach ($objItem in $colItems)
			{
				$serial = $objItem.SerialNumber
				$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(2,$i)) 
				[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @($serial)) 
			}
			   
   			#Get Operating System and Service Pack.
			$ErrorActionPreference = "SilentlyContinue"
   			$colItems = get-wmiobject -class “Win32_OperatingSystem” -computername $strComputer 
			$ErrorActionPreference = "Continue"
			
			foreach ($objItem in $colItems)
			{
				$Opersys = $objItem.Caption
				$ServicePk = $objItem.CSDVersion
				
				#Write Operating System to OpenOffice Calc
				$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(3,$i)) 
				[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @($Opersys)) 
				
				#Write Service Pack to OpenOffice Calc
				$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(4,$i)) 
				[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @($ServicePk)) 
			}
   
   			#Get Processor and Speed.
			$ErrorActionPreference = "SilentlyContinue"
   			$colProcessor = get-wmiobject -class “Win32_Processor” -computername $strComputer 
			$ErrorActionPreference = "Continue"
			
			foreach ($objItem in $colProcessor)
			{
				$cpu = $objItem.Name
				
				#Write CPU to OpenOffice Calc
				$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(5,$i)) 
				[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @($cpu))
			}
	
			#Get Memory Info.
			$ErrorActionPreference = "SilentlyContinue"
			$colItems = get-wmiobject -class “Win32_MemoryArray” -computername $strComputer 
			$ErrorActionPreference = "Continue"
			
			foreach ($objItem in $colItems) 
			{
				if ($objItem.EndingAddress -gt 4096)
					{
					$memory = "{0:N0}MB" -f($objItem.EndingAddress / 1024)
					
					#Write Memory to OpenOffice Calc
					$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(6,$i)) 
					[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @($memory)) 
					
					}
			}
		
			#Get Disk Information.
			$ErrorActionPreference = "SilentlyContinue"
   			$colProcessor = get-wmiobject -class “Win32_LogicalDisk” -computername $strComputer
			$ErrorActionPreference = "Continue"
			
			foreach ($objItem in $colProcessor)
			{
				$drivename =  $objItem.DeviceID
				$drivetype = $objItem.DriveType
				if ($drivename -ne "C:", $drivetype -eq 3)
				{
				#If not equal C: - Do Nothing.
				}
				if ($objItem.Size -gt 1073741824 -and $drivename -eq "C:")
					{
					$drivespace = "{0:N1}GB" -f($objItem.Size / 1073741824)
					$freespace = "{0:N1}GB" -f($objItem.FreeSpace / 1073741824) 
					
					#Write C: Size to OpenOffice Calc
					$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(7,$i)) 
					[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @($drivespace)) 
					#Write C: Freespace to OpenOffice Calc
					$cell = [unoidl.com.sun.star.table.XCellRange].getMethod('getCellByPosition').invoke($sheet.Value, @(8,$i)) 
					[unoidl.com.sun.star.table.XCell].getMethod('setFormula').invoke($cell, @($freespace)) 
					}
				else 
					{
					}
		                                                                 
			}
		#Increment row
		$i=$i+1   
		}
}



