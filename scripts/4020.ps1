﻿#Generated Form Function
function ProgressMessage {
	########################################################################
	# Code Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
	# Generated On: 29/01/2013 11:01 AM
	# Generated By: admstpierdj
	########################################################################
	
	param(	#parameters with default values assigned
		[String]$LabelText="Message",
		[String]$FormTitle="Form Title",
#		[int]$nSecondsToWait=3,
#		[int]$Buttons = 0,
		[int]$FontSize = 12,
		[String]$ICOpath=""
	)
	
	If ( Get-Variable -Name ProgMsgForm1 -Scope Global -ErrorAction SilentlyContinue ) {
		$ProgMsgForm1.close()	#Kill previous Progress Message to prevent lost handles
	}
	If ($LabelText -eq ""){
		Return
	}
	
	$LabelText="`r`n   "+$LabelText+"   `r`n " #add space around the message
		
	#region Import the Assemblies
	[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
	[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
	#endregion

	#region Generated Form Objects
	$global:ProgMsgForm1 = New-Object System.Windows.Forms.Form
	$ProgMsgLabel1 = New-Object System.Windows.Forms.Label
	$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
	#endregion Generated Form Objects

	#region Generated Form Code
	$ProgMsgForm1.AutoSize = $True
	$ProgMsgForm1.AutoSizeMode = 0
#	$System_Drawing_Size = New-Object System.Drawing.Size
	#$System_Drawing_Size.Height = 113
	#$System_Drawing_Size.Width = 255
#	$ProgMsgForm1.ClientSize = $System_Drawing_Size
	$ProgMsgForm1.DataBindings.DefaultDataSourceUpdateMode = 0
	
	#add Icon to dialog
	If ( ($ICOpath -ne "") -and (Test-Path "$ICOpath") ) {
		Try {	#If the ICO file is NFG, ignore and move on
			$ProgMsgForm1.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$ICOpath")
		} catch { } #use default ICO
	}
	
	$ProgMsgForm1.Name = "form1"
	$ProgMsgForm1.StartPosition = 1 #Center of the Screen
	$ProgMsgForm1.Text = "$FormTitle"

#	$ProgMsgLabel1.AutoEllipsis = $True	#handle text that goes beyond width of Label control
	$ProgMsgLabel1.AutoSize = $True
	$ProgMsgLabel1.DataBindings.DefaultDataSourceUpdateMode = 0

	$System_Drawing_Point = New-Object System.Drawing.Point
#	$System_Drawing_Point.X = 10
#	$System_Drawing_Point.Y = 10
	$ProgMsgLabel1.Location = $System_Drawing_Point
	$ProgMsgLabel1.Name = "label1"
#	$System_Drawing_Size = New-Object System.Drawing.Size
##	$System_Drawing_Size.Height = 13
##	$System_Drawing_Size.Width = 35
#	$ProgMsgLabel1.Size = $System_Drawing_Size
	$ProgMsgLabel1.TabIndex = 0
	$ProgMsgLabel1.Text = "$LabelText"
	$ProgMsgLabel1.TextAlign = 2
	$ProgMsgLabel1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",$FontSize,1,3,1)
	$ProgMsgForm1.Controls.Add($ProgMsgLabel1)

	#endregion Generated Form Code

	#Save the initial state of the form
	$InitialFormWindowState = $ProgMsgForm1.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$ProgMsgForm1.add_Load($OnLoadForm_StateCorrection)
	#Show the Form
	#$ProgMsgForm1.ShowDialog()| Out-Null #ShowDialog waits until it is closed
	$ProgMsgForm1.Show()		#show forms and keep on going
	$ProgMsgForm1.activate()	#Make sure its on top
	
	return $ProgMsgForm1	#need to do this to kill form later (now optional b/c $ProgMsgForm1 is made global)
} #End Function
 
 
 
#Call the Function
$ProgressObj=ProgressMessage "this is text to display this is text to display this is text to display this is text to display this is text to display this is text to display this is text to display this is text to display this is text to display this is text to display this is text to display this is text to display" "My title"
Echo "doing other stuff"
Start-Sleep -Second 2
Echo "doing other stuff"
Start-Sleep -Second 2
#$ProgressObj.Close()	#if you forget to close previous, it stays on the screen and you cant kill it!


$ProgressObj=ProgressMessage "LEt's see if this works too"
Echo "doing other stuff"
Start-Sleep -Second 3
Echo "doing other stuff"
Start-Sleep -Second 2
#$ProgressObj.Close()

ProgressMessage ""	#close progress message
