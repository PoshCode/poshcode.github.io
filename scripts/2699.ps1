#######################################################################################################################
# File:             wizard_template.ps1						                                                          #
# Author:           Alexander Petrovskiy                                                                              #
# Publisher:        Alexander Petrovskiy, PowerShellDevTools.WordPress.Com                                            #
# Copyright:        © 2010-2011 Alexander Petrovskiy, PowerShellDevTools.WordPress.Com. All rights reserved.          #
# Usage:            To run this example no preparations needed.														  #
#					There also are the following settings you may be intersted in:									  #
#                   1. the wizard caption	                                                                          #
#                   2. default size of the wizard						                                              #
#                   3. default size of the wizard's buttons             				                              #
#                   4. button labels                                        										  #
#                   5. right-to-left layout     	    												              #
#                   All the settings mentioned are placed inside the 'adjustable settings' region                     #
#                   Please provide feedback in the PowerShellDevTools.WordPress.Com blog.                             #
#######################################################################################################################
cls
Set-StrictMode -Version 2
#region host preparations
if ($Host.Name -eq 'ConsoleHost')
{
	Add-Type -AssemblyName System.Windows.Forms;
	Add-Type -AssemblyName System.Drawing;
}
#endregion host preparations
#region the resulting wizard
	#region adjustable settings
		#region controls settings
		# Form size and caption
		[string]$script:constWizardInitialCaption = `
			'This is a sample wizard';
		[int]$script:constWizardWidth = `
			[System.Windows.Forms.SystemInformation]::VirtualScreen.Width / 2;
		[int]$script:constWizardHeight = `
			[System.Windows.Forms.SystemInformation]::VirtualScreen.Height / 2;
		# Buttons Next, Back, Cancel, Finish
		[int]$script:constButtonHeight = 23;
		[int]$script:constButtonWidth = 75;
		[int]$script:constButtonAreaHeight = `
			$script:constButtonHeight * 2;
		[string]$script:constButtonNextName = '&Next';
		[string]$script:constButtonBackName = '&Back';
		[string]$script:constButtonFinishName = '&Finish';
		[string]$script:constButtonCancelName = '&Cancel';
		# Step display name and description
		[int]$script:constLabelStepDisplayNameLeft = 5;
		[int]$script:constLabelStepDisplayNameTop = 0;
		[float]$script:constLabelStepDisplayNameFontSize = 16;
		[int]$script:constLabelStepDescriptionLeft = 5;
		[int]$script:constLabelStepDescriptionTop = 30;
		# Form properties
		[bool]$script:constWizardRigthToLeft = $false;
		# Initial step number
		[int]$script:currentStep = 0;
		#endregion controls settings
	#endregion adjustable settings
	#region mandatory settings
		#region Initialization of the SplitContainer controls
		# The outer split container
		[System.Windows.Forms.SplitContainer]$script:splitOuter = `
			New-Object System.Windows.Forms.SplitContainer;
			$script:splitOuter.Dock = [System.Windows.Forms.DockStyle]::Fill;
			$script:splitOuter.IsSplitterFixed = $true;
			$script:splitOuter.Orientation = `
				[System.Windows.Forms.Orientation]::Horizontal;
			$script:splitOuter.SplitterWidth = 5;
		# The inner split container
		[System.Windows.Forms.SplitContainer]$script:splitInner = `
			New-Object System.Windows.Forms.SplitContainer;
			$script:splitInner.Dock = [System.Windows.Forms.DockStyle]::Fill;
			$script:splitInner.IsSplitterFixed = $true;
			$script:splitInner.Orientation = `
				[System.Windows.Forms.Orientation]::Horizontal;
			$script:splitInner.SplitterWidth = 5;
			$script:splitOuter.Panel1.Controls.Add($script:splitInner);
		# The labels for the curent step name and description
		[System.Windows.Forms.Label]$script:lblStepDisplayName = `
			New-Object System.Windows.Forms.Label;
			$script:lblStepDisplayName.Left = `
				$script:constLabelStepDisplayNameLeft;
			$script:lblStepDisplayName.Top = `
				$script:constLabelStepDisplayNameTop;
			[System.Drawing.Font]$private:font = `
				$script:lblStepDisplayName.Font;
			$private:font = `
				New-Object System.Drawing.Font($private:font.Name, `
						$script:constLabelStepDisplayNameFontsize, `
			            $private:font.Style, $private:font.Unit, `
			            $private:font.GdiCharSet, $private:font.GdiVerticalFont );
			$script:lblStepDisplayName.Font = $private:font;
		[System.Windows.Forms.Label]$script:lblStepDescription = `
			New-Object System.Windows.Forms.Label;
			$script:lblStepDescription.Left = `
				$script:constLabelStepDescriptionLeft;
			$script:lblStepDescription.Top = `
				$script:constLabelStepDescriptionTop;
		$script:splitInner.Panel1.Controls.AddRange(($script:lblStepDisplayName, `
			$script:lblStepDescription));
		#endregion Initialization of the SplitContainer controls
		#region buttons functions
		function Enable-FinishButton
		{
			$script:btnNext.Enabled = $false;
			$script:btnNext.Visible = $false;
			$script:btnFinish.Enabled = $true;
			$script:btnFinish.Visible = $true;
		}
		function Enable-NextButton
		{
			$script:btnNext.Enabled = $true;
			$script:btnNext.Visible = $true;
			$script:btnFinish.Enabled = $false;
			$script:btnFinish.Visible = $false;
		}
		function Enable-BackButton
		{
			$script:btnBack.Enabled = $true;
			$script:btnBack.Visible = $true;
			$script:btnCancel.Enabled = $false;
			$script:btnCancel.Visible = $false;
		}
		function Enable-CancelButton
		{
			$script:btnBack.Enabled = $false;
			$script:btnBack.Visible = $false;
			$script:btnCancel.Enabled = $true;
			$script:btnCancel.Visible = $true;
		}
		#endregion buttons functions
		#region the Next and Back buttons
		[System.Windows.Forms.Button]$script:btnNext = `
			New-Object System.Windows.Forms.Button;
		$script:btnNext.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor `
			[System.Windows.Forms.AnchorStyles]::Right -bor `
			[System.Windows.Forms.AnchorStyles]::Top;
		$script:btnNext.Text = $script:constButtonNextName;
		[System.Windows.Forms.Button]$script:btnBack = `
			New-Object System.Windows.Forms.Button;
		$script:btnBack.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor `
			[System.Windows.Forms.AnchorStyles]::Right -bor `
			[System.Windows.Forms.AnchorStyles]::Top;
		$script:btnBack.Text = $script:constButtonBackName;
		$script:splitOuter.Panel2.Controls.AddRange(($script:btnBack, $script:btnNext));
		#endregion the Next and Back buttons
		#region the Finish and the Cancel buttons
		[System.Windows.Forms.Button]$script:btnFinish = `
			New-Object System.Windows.Forms.Button;
		$script:btnFinish.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor `
			[System.Windows.Forms.AnchorStyles]::Right -bor `
			[System.Windows.Forms.AnchorStyles]::Top;
		$script:btnFinish.Text = $script:constButtonFinishName;
		[System.Windows.Forms.Button]$script:btnCancel = `
			New-Object System.Windows.Forms.Button;
		$script:btnCancel.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor `
			[System.Windows.Forms.AnchorStyles]::Right -bor `
			[System.Windows.Forms.AnchorStyles]::Top;
		$script:btnCancel.Text = $script:constButtonCancelName;
		Enable-CancelButton;
		Enable-NextButton;
		$script:splitOuter.Panel2.Controls.AddRange(($script:btnCancel, $script:btnFinish));
		#endregion the Finish and the Cancel buttons
		#region Initialization of the main form
		$script:frmWizard = $null;
		[System.Windows.Forms.Form]$script:frmWizard = `
			New-Object System.Windows.Forms.Form;
		$script:frmWizard.Controls.Add($script:splitOuter);
		# left-to-right and right-to-left
		if ($script:constWizardRigthToLeft)
		{
			$script:frmWizard.RightToLeft = `
				[System.Windows.Forms.RightToLeft]::Yes;
			$script:frmWizard.RightToLeftLayout = $true;
		}
		else
		{
			$script:frmWizard.RightToLeft = `
				[System.Windows.Forms.RightToLeft]::No;
			$script:frmWizard.RightToLeftLayout = $false;
		}
		$script:frmWizard.Text = $script:constWizardInitialCaption;
		#endregion Initialization of the main form
	#endregion mandatory settings
	#region the Wizard steps
	[System.Collections.ArrayList]$script:wzdSteps = `
		New-Object System.Collections.ArrayList;
		# Here we create an 'enumeration' (PSObject) 
		# and begin filling ArrayList $script:wzdSteps with Panel controls
		[System.EventHandler]$script:hndlRunControlsAdd = `
			{try{$script:splitInner.Panel2.Controls.Add($script:wzdSteps[$script:currentStep]);}
			catch{Write-Debug $Error[0]; Write-Debug $global:Error[0];}};
		#region function New-WizardStep
		function New-WizardStep
		{
			param(
				  [string]$StepName,
				  [string]$StepDisplayName,
				  [string]$StepDescription = ''
				  )
			# Storing parameters in step arrays
			Add-Member -InputObject $script:steps -MemberType NoteProperty `
				-Name $StepName -Value $script:wzdSteps.Count;
			$null = $script:stepDisplayNames.Add($StepDisplayName);
			$null = $script:stepDescriptions.Add($StepDescription);
			# Adding a fake scriptblock to keep counters
			$null = $script:stepscriptblocks.Add({});
			# Create and add the new step's panel to the array
			[System.Windows.Forms.Panel]$private:panel = `
				New-Object System.Windows.Forms.Panel;
			$null = $script:wzdSteps.Add($private:panel);
			$script:currentStep = $script:wzdSteps.Count - 1;

			$script:splitInner.Panel2.Controls.Add($script:wzdSteps[$script:currentStep]);

			$script:wzdSteps[$script:currentStep].Dock = `
				[System.Windows.Forms.DockStyle]::Fill;
			# To restore initial state for this code running before the user accesses the wizard.
			$script:currentStep = 0;
		}
		#endregion function New-WizardStep
		#region function Add-ControlToStep
		function Add-ControlToStep
		# Adds a control of selected type to a wizard step
		{
			param(
				  [Parameter(Mandatory=$true)]
				  [string]$StepNumber,
				  [Parameter(Mandatory=$true)]
				  [string]$ControlType,
				  [Parameter(Mandatory=$true)]
				  [string]$ControlName,
				  [int]$ControlTop,
				  [int]$ControlLeft,
				  [int]$ControlHeight,
				  [int]$ControlWidth,
				  [string]$ControlData
				 )
			$private:ctrl = $null;
			try{
				$private:ctrl = New-Object $ControlType;
			}catch{Write-Error "Unable to create a control of $($ControlType) type";}
			try{
				$private:ctrl.Name = $ControlName;
			}catch{Write-Error "Unable to set the Name property with value $($ControlName) to a control of the $($ControlType) type";}
			try{
				$private:ctrl.Top = $ControlTop;
			}catch{Write-Error "Unable to set the Top property with value $($ControlTop) to a control of the $($ControlType) type";}
			try{
				$private:ctrl.Left = $ControlLeft;
			}catch{Write-Error "Unable to set the Left property with value $($ControlLeft) to a control of the $($ControlType) type";}
			try{
				$private:ctrl.Height = $ControlHeight;
			}catch{Write-Error "Unable to set the Height property with value $($ControlHeight) to a control of the $($ControlType) type";}
			try{
				$private:ctrl.Width = $ControlWidth;
			}catch{Write-Error "Unable to set the Width property with value $($ControlWidth) to a control of the $($ControlType) type";}
			try{
				$private:ctrl.Text = $ControlData;
			}catch{Write-Error "Unable to set the Text property with value $($ControlData) to a control of the $($ControlType) type";}
			try{
				$wzdSteps[$StepNumber].Controls.Add($private:ctrl);
			}catch{Write-Error "Unable to add a control of $($ControlType) type to the step $($StepNumber)";}
		}
		#endregion function Add-ControlToStep
		#region function Add-CodeToStep
		function Add-CodeToStep
		# Adds a scriptblock to a wizard step
		{
			param(
				  [Parameter(Mandatory=$true)]
				  [string]$StepNumber,
				  [Parameter(Mandatory=$true)]
				  [scriptblock]$StepCode
				 )
			$script:stepScriptblocks[$StepNumber] = $StepCode;
		}
		#endregion function Add-CodeToStep
		#region Step data arrays
		[psobject]$script:steps = New-Object psobject;
		[System.Collections.ArrayList]$script:stepDisplayNames = `
			New-Object System.Collections.ArrayList;
		[System.Collections.ArrayList]$script:stepDescriptions = `
			New-Object System.Collections.ArrayList;
		[System.Collections.ArrayList]$script:stepScriptblocks = `
			New-Object System.Collections.ArrayList;
		#endregion Step data arrays
	#endregion the Wizard steps
	#region events of the wizard controls
		#region resizing
			#region button sizes
	function Set-NextButtonLeft
	{
		param([int]$Left)
		$script:btnNext.Left = $Left;
		$script:btnFinish.Left = $Left;
	}
	function Set-NextButtonTop
	{
		param([int]$Top)
		$script:btnNext.Top = $Top;
		$script:btnFinish.Top = $Top;
	}
	function Set-BackButtonLeft
	{
		param([int]$Left)
		$script:btnBack.Left = $Left;
		$script:btnCancel.Left = $Left;
	}
	function Set-BackButtonTop
	{
		param([int]$Top)
		$script:btnBack.Top = $Top;
		$script:btnCancel.Top = $Top;
	}
			#endregion button sizes
			#region function Initialize-WizardControls
	function Initialize-WizardControls
	<#
		.SYNOPSIS
			The Initialize-WizardControls function sets the wizard common controls to predefined positions.
	
		.DESCRIPTION
			The Initialize-WizardControls function does the following:
			- sets Top, Left, Width and Height properties of the wizard buttons
			- positions of the step labels
			- sets the SplitterDistance property of both Splitcontainer controls
	
		.EXAMPLE
			PS C:\> Initialize-WizardControls
			This example shows how to step the wizard forward.
	
		.INPUTS
			No input
	
		.OUTPUTS
			No output
	#>
	{
		# Set sizes of buttons
		$script:btnNext.Height = $script:constButtonHeight;
		$script:btnNext.Width = $script:constButtonWidth;
		$script:btnBack.Height = $script:constButtonHeight;
		$script:btnBack.Width = $script:constButtonWidth;
		$script:btnFinish.Height = $script:btnNext.Height;
		$script:btnFinish.Width = $script:btnNext.Width;
		$script:btnCancel.Height = $script:btnBack.Height;
		$script:btnCancel.Width = $script:btnBack.Width;
		# SplitterDistance of the outer split container
		# in other words, the area where Next and Back buttons are placed
		$script:splitOuter.SplitterDistance = `
			$script:splitOuter.Height - `
			$script:constButtonAreaHeight;
		
		# Placements of the buttons
		if ($script:constWizardRigthToLeft)
		{
			Set-NextButtonLeft 10;
			Set-BackButtonLeft ($script:constButtonWidth + 20);
		}
		else
		{
			Set-NextButtonLeft ($script:splitOuter.Width - `
				$script:constButtonWidth - 10);
			Set-BackButtonLeft ($script:splitOuter.Width - `
				$script:constButtonWidth - `
				$script:constButtonWidth - 20);
		}
		Set-NextButtonTop (($script:constButtonAreaHeight - $script:constButtonHeight) / 2);
		Set-BackButtonTop (($script:constButtonAreaHeight - $script:constButtonHeight) / 2);
		
		# SplitterDistance of the inner split container
		# this is the place where step name is placed
		$script:splitInner.SplitterDistance = `
			$script:constButtonAreaHeight * 1.5;
		
		# Step Display Name and Description labels
		$script:lblStepDisplayName.Width = `
			$script:splitInner.Panel1.Width - `
			$script:constLabelStepDisplayNameLeft * 2;
		$script:lblStepDescription.Width = `
			$script:splitInner.Panel1.Width - `
			$script:constLabelStepDescriptionLeft * 2;
			
		# Refresh after we have changed placements of the controls
		[System.Windows.Forms.Application]::DoEvents();
	}
			#endregion function Initialize-WizardControls
	[System.EventHandler]$script:hndlFormResize = {Initialize-WizardControls;}
	[System.EventHandler]$script:hndlFormLoad = {Initialize-WizardControls;}
	#[System.Windows.Forms.MouseEventHandler]$script:hndlSplitMouseMove = `
	#	{Initialize-WizardControls;}
	# Initial arrange on Load form.
	$script:frmWizard.add_Load($script:hndlFormLoad);
	#$script:frmWizard.add_Resize($script:hndlFormResize);
	$script:splitOuter.add_Resize($script:hndlFormResize);
		#endregion resizing
		#region steps
			#region function Invoke-WizardStep
	function Invoke-WizardStep
	<#
		.SYNOPSIS
			The Invoke-WizardStep function sets active panel on the wizard form.
	
		.DESCRIPTION
			The Invoke-WizardStep function does the following:
			- changes internal variable $script:currentStep
			- sets/resets .Enabled property of btnNext and btnBack
			- changes .Dock and .Left properties of every panel
	
		.PARAMETER  Forward
			The optional parameter Forward is used to point out the direction the wizard goes.
	
		.EXAMPLE
			PS C:\> Invoke-WizardStep -Forward $true
			This example shows how to step the wizard forward.
	
		.INPUTS
			System.Boolean
	
		.OUTPUTS
			No output
	#>
	{
		[CmdletBinding()]
		param(
			  [Parameter(Mandatory=$false)]
			  [bool]$Forward = $true
			  )
		Begin{}
		Process{
			# run the step code
			try{
				$script:stepScriptblocks[$script:currentStep].Invoke();
			} catch {return;} #Cancel step
			if ($Forward)
			{
				Enable-BackButton;
				if ($script:currentStep -lt ($script:wzdSteps.Count - 1))
				{$script:currentStep++;}
				if ($script:currentStep -lt ($script:wzdSteps.Count - 1))
				{
					# step forward but not the last step
					Enable-NextButton;
				}
				else
				{	
					# the last step
					Enable-FinishButton;
				}
			}
			else
			{
				# go backward
				Enable-NextButton;
				if ($script:currentStep -gt 0)
				{$script:currentStep--;}
				if ($script:currentStep -gt 0)
				{
					# step backward but not the first one
					Enable-BackButton;
				}
				else
				{
					# the first step
					Enable-CancelButton;
				}
			}		
			for($private:i = 0; $private:i -lt $script:wzdSteps.Count;
				$private:i++)
			{
				if ($private:i -ne $script:currentStep)
				{	
					$script:wzdSteps[$private:i].Dock = `
						[System.Windows.Forms.DockStyle]::None;
					$script:wzdSteps[$private:i].Left = 10000;
				}
				else
				{
					$script:wzdSteps[$private:i].Dock = `
						[System.Windows.Forms.DockStyle]::Fill;
					$script:wzdSteps[$private:i].Left = 0;
				}
			}
			$script:lblStepDisplayName.Text = `
				$script:stepDisplayNames[$script:currentStep];
			$script:lblStepDescription.Text = `
				$script:stepDescriptions[$script:currentStep];
		}
		End{}
	}
			#endregion function Invoke-WizardStep
			#region function Initialize-WizardStep
	function Initialize-WizardStep
	# This is the selfsufficient function doing all the necessary
	# calculations for controls on each panel.
	# Also from the code can be seen how to address the panel you are interesting in
	# using the 'enumeration' created earlier
	# for example, $script:wzdSteps[$script:steps.Welcome]
	{
		$script:lblStepDisplayName.Text = `
			$script:stepDisplayNames[$script:currentStep];
		$script:lblStepDescription.Text = `
			$script:stepDescriptions[$script:currentStep];
	}
			#endregion function Initialize-WizardStep
			#region $hndlStepForward
	[System.EventHandler]$hndlStepForward = {
		# serve controls' data
		Initialize-WizardStep;
		# switch panels
		Invoke-WizardStep $true;
	}
			#endregion $hndlStepForward
			#region $hndlStepBack
	[System.EventHandler]$hndlStepBack = {
		# switch panels
		Invoke-WizardStep $false;
	}
			#endregion $hndlStepBack
			#region $hndlFinish
	[System.EventHandler]$hndlFinish = {
		# ask for exit
		[System.Windows.Forms.DialogResult]$private:res = `
			[System.Windows.Forms.MessageBox]::Show("Are you sure?", `
					"Question on exit", `
					[System.Windows.Forms.MessageBoxButtons]::YesNo);
		if ($res -eq [System.Windows.Forms.DialogResult]::Yes){
			# close the wizard
			$frmWizard.Close();
		}
	}
			#endregion $hndlFinish
			#region $hndlCancel
	[System.EventHandler]$hndlCancel = {
		# close the wizard
		$frmWizard.Close();
	}
			#endregion $hndlCancel
			#region wizard buttons' clicks
	$script:btnNext.add_Click($script:hndlStepForward);
	$script:btnBack.add_Click($script:hndlStepBack);
	$script:btnFinish.add_Click($script:hndlFinish);
	$script:btnCancel.add_Click($script:hndlCancel);
			#endregion wizard buttons' clicks
		#endregion steps
	#endregion events of the wizard controls
	#region wizard initialization
		#region function Initialize-Wizard
	function Initialize-Wizard
	# This is one more selfsufficient function written to make
	# the latest preparations for the form run
	{
		#region control settings
		$script:frmWizard.Width = $script:constWizardWidth;
		$script:frmWizard.Height = $script:constWizardHeight;
		#endregion control settings
		Initialize-WizardStep;
	}
		#endregion function Initialize-Wizard
	#endregion wizard initialization
#endregion the resulting wizard


		# Step 1: Welcome
		New-WizardStep 'Welcome' `
			'This is the first step' `
			'Welcome to the PowerShell Wizard, the our dear customer!';
		# Add a label
		# Please note that we can use the enumeration $steps which is being created runtime
		# on a call of the New-WizardStep function
		Add-ControlToStep $steps.Welcome `
			System.Windows.Forms.Label `
			'lblWelcome' 20 10 50 300 `
			'This Wizard carries you through the steps you need to collect the files from a given path';
		
		# Step 2
		New-WizardStep 'Input' `
			'Step Two' `
			'Here you type some in controls, plz';
		# Add a label
		Add-ControlToStep $steps.Input `
			System.Windows.Forms.Label `
			'lblInput' 20 10 20 300 `
			'Please type the path to a catalog';
		# Add a text box
		Add-ControlToStep $steps.Input `
			System.Windows.Forms.TextBox `
			'txtInput' 40 10 20 300
		# Add the code which requires that text box was not empty
		Add-CodeToStep $steps.Input `
			-StepCode {
					[string]$private:path = `
						$wzdSteps[$steps.Input].Controls['txtInput'].Text;
					if ($private:path.Length -eq 0)
					{
						# stop the step
						throw;
					}
					if (-not [System.IO.Directory]::Exists($private:path))
					{
						# stop the step
						throw;
					}
				}

		# Step 3
		New-WizardStep 'Progress' `
			'The third one' `
			'Wait, please. Sip a coffee' ;
		# Add a progress bar
		Add-ControlToStep $steps.Progress `
			'System.Windows.Forms.ProgressBar' `
			'pbDir' 200 50 100 400
		Add-CodeToStep $steps.Progress `
			-StepCode {
					# set progress bar maximum
					$wzdSteps[$steps.Progress].Controls['pbDir'].Minimum = 0;
					$wzdSteps[$steps.Progress].Controls['pbDir'].Value = 0;
					$wzdSteps[$steps.Progress].Controls['pbDir'].Maximum = `
						(Get-ChildItem $wzdSteps[$steps.Input].Controls['txtInput'].Text).Length;
					# clear the list box (from the next step)
					$wzdSteps[$steps.Output].Controls['lbxFiles'].Items.Clear();
					# add file names to the list box
					Get-ChildItem $wzdSteps[$steps.Input].Controls['txtInput'].Text | %{
							$wzdSteps[$steps.Progress].Controls['pbDir'].Value++;
							$wzdSteps[$steps.Output].Controls['lbxFiles'].Items.Add($_.Name);
						}
				}
		
		# Step 4
		New-WizardStep 'Output' 'Fourth' `
			'Now awake and read the output';
		# Add a list box
		Add-ControlToStep $steps.Output `
			System.Windows.Forms.ListBox `
			lbxFiles 50 50 300 400
        
		# Step 5: Finish
        New-WizardStep 'Finish' 'Finish!' 'Bye!';
				
		Initialize-Wizard;
		# Set the second step as active
		Invoke-WizardStep -Forward $true;
				
		$script:frmWizard.ShowDialog() | Out-Null;
