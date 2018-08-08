
$OnLoadFormEvent={
#TODO: Initialize Form Controls here
# Create an Array for List of Properties which the user sees
 
$array = @("Bios_Information","Computer_System_Information","Processor_Information")
 
# Appending the list of items in $array to combobox
 
$array | ForEach-Object {Load-ComboBox -ComboBox $combobox1 -Append -Items $_ }
 
}





#region Control Helper Functions
function Load-ComboBox 
{
<#
	.SYNOPSIS
		This functions helps you load items into a ComboBox.

	.DESCRIPTION
		Use this function to dynamically load items into the ComboBox control.

	.PARAMETER  ComboBox
		The ComboBox control you want to add items to.

	.PARAMETER  Items
		The object or objects you wish to load into the ComboBox's Items collection.

	.PARAMETER  DisplayMember
		Indicates the property to display for the items in this control.
	
	.PARAMETER  Append
		Adds the item(s) to the ComboBox without clearing the Items collection.
	
	.EXAMPLE
		Load-ComboBox $combobox1 "Red", "White", "Blue"
	
	.EXAMPLE
		Load-ComboBox $combobox1 "Red" -Append
		Load-ComboBox $combobox1 "White" -Append
		Load-ComboBox $combobox1 "Blue" -Append
	
	.EXAMPLE
		Load-ComboBox $combobox1 (Get-Process) "ProcessName"
#>
	Param (
		[ValidateNotNull()]
		[Parameter(Mandatory=$true)]
		[System.Windows.Forms.ComboBox]$ComboBox,
		[ValidateNotNull()]
		[Parameter(Mandatory=$true)]
		$Items,
	    [Parameter(Mandatory=$false)]
		[string]$DisplayMember,
		[switch]$Append
	)
	
	if(-not $Append)
	{
		$ComboBox.Items.Clear()	
	}
	
	if($Items -is [Object[]])
	{
		$ComboBox.Items.AddRange($Items)
	}
	elseif ($Items -is [Array])
	{
		$ComboBox.BeginUpdate()
		foreach($obj in $Items)
		{
			$ComboBox.Items.Add($obj)	
		}
		$ComboBox.EndUpdate()
	}
	else
	{
		$ComboBox.Items.Add($Items)	
	}

	$ComboBox.DisplayMember = $DisplayMember	
}
#endregion

$buttonResetComputerName_Click={
	#TODO: Place custom script here
	$textbox1.Clear()
}

$buttonGO_Click={
	#TODO: Place custom script here
Try {
	# Work only if Textbox1.text input is Not Null.
 
	if ($textbox1.Text -ne $null)
	{
	# Selected index is greater than -1 (0,1,2), Iterate for each selected item  generate bios info and Out-grid view
	 
	 if ($combobox1.SelectedIndex -gt -1 -and $combobox1.SelectedItem -eq "Bios_Information")
	 
	 {
	 
	$servername = $textbox1.Text
	 
	 Get-WmiObject -Class win32_bios -ComputerName $servername -ea 'Stop' |
	 
	 Out-GridView -Title "$($combobox1.SelectedItem) for $servername"
	 
	}
	 
	# Selected index is greater than -1 (0,1,2), Iterate for each selected item  generate bios info and Out-grid view
	 
	 elseif ($combobox1.SelectedIndex -gt -1 -and $combobox1.SelectedItem -eq "Computer_System_Information")
	 
	 {
	 
	$servername = $textbox1.Text
	 
	Get-WmiObject -Class Win32_ComputerSystem -ComputerName $servername -ea 'Stop' |
	 
	 Out-GridView -Title "$($combobox1.SelectedItem) for $servername"
	 
	 }
	 
	 <# Selected index is greater than -1 (0,1,2), Iterate for each selected item  generate processor info and Out-grid view, error action stop
	 
	 so that we can trap the error in try catch block #>
	 
	 elseif ($combobox1.SelectedIndex -gt -1 -and $combobox1.SelectedItem -eq "Processor_Information")
	 
	 {
	 
	 
	$servername = $textbox1.Text
	 
	 Get-WmiObject -Class Win32_Processor -ComputerName $servername -ea 'Stop' |
	 
	 Out-GridView -Title "$($combobox1.SelectedItem) for $servername"
	 
	 }
	 
	 }
	 
	}

 # Pop up a windows message box indicating the type of error.
 
 catch {
 [void][System.Windows.Forms.MessageBox]::Show(" $($servername) is ShutDown or not Reachable over the Network","Information")
 
}
}
