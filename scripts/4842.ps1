﻿#######################################################################################################################
# File:             Add-on.PublishOnline.psm1                                                                         #
# Author:           Kirk Munro                                                                                        #
# Publisher:        Quest Software, Inc.                                                                              #
# Copyright:        Â© 2010 Quest Software, Inc.. All rights reserved.                                                 #
# Usage:            To load this module in your Script Editor:                                                        #
#                   1. Open the Script Editor.                                                                        #
#                   2. Select "PowerShell Libraries" from the File menu.                                              #
#                   3. Check the Add-on.PublishOnline module.                                                         #
#                   4. Click on OK to close the "PowerShell Librar$ies" dialog.                                        #
#                   Alternatively you can load the module from the embedded console by invoking this:                 #
#                       Import-Module -Name Add-on.PublishOnline                                                      #
#                   Please provide feedback on the PowerGUI Forums.                                                   #
#######################################################################################################################

Set-StrictMode -Version 2

#region Initialize the Script Editor Add-on.

if ($Host.Name â€“ne 'PowerGUIScriptEditorHost') { return }
if ($Host.Version -lt '2.1.0.1200') {
	[System.Windows.Forms.MessageBox]::Show("The ""$(Split-Path -Path $PSScriptRoot -Leaf)"" Add-on module requires version 2.1.0.1200 or later of the Script Editor. The current Script Editor version is $($Host.Version).$([System.Environment]::NewLine * 2)Please upgrade to version 2.1.0.1200 and try again.","Version 2.1.0.1200 or later is required",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
	return
}

$se = [Quest.PowerGUI.SDK.ScriptEditorFactory]::CurrentInstance

#endregion

#region Load resources from disk.

$iconLibrary = @{
	PublishOnlineIcon16 = New-Object System.Drawing.Icon -ArgumentList "$PSScriptRoot\Resources\PublishOnline.ico",16,16
	PublishOnlineIcon32 = New-Object System.Drawing.Icon -ArgumentList "$PSScriptRoot\Resources\PublishOnline.ico",32,32
}

$imageLibrary = @{
	PublishOnlineImage16 = $iconLibrary['PublishOnlineIcon16'].ToBitmap()
	PublishOnlineImage32 = $iconLibrary['PublishOnlineIcon32'].ToBitmap()
}

#endregion

#region Define the Script Signing Options dialog.

$publishOnlineDialogCode = @'
using System;
using System.Windows.Forms;

namespace Addon
{
	namespace PublishOnline
	{
		public partial class PublishOnlineForm : Form
		{
			public PublishOnlineForm()
			{
				InitializeComponent();
				this.comboBoxDuration.SelectedIndex = 2;
			}

			private void buttonOK_Click(object sender, EventArgs e)
			{
				this.DialogResult = DialogResult.None;
				if (this.textBoxTitle.Text.Trim().Length == 0)
				{
					MessageBox.Show(this, "You must provide a title for the document you are publishing.", "Title is required", MessageBoxButtons.OK, MessageBoxIcon.Error);
					this.textBoxTitle.SelectAll();
					this.textBoxTitle.Focus();
				}
				else if (this.textBoxAuthor.Text.Trim().Length == 0)
				{
					MessageBox.Show(this, "You must provide an author for the document you are publishing.", "Author is required", MessageBoxButtons.OK, MessageBoxIcon.Error);
					this.textBoxAuthor.SelectAll();
					this.textBoxAuthor.Focus();
				}
				else if (this.textBoxTitle.Text.Trim().Length == 0)
				{
					MessageBox.Show(this, "You must provide a description for the document you are publishing.", "Description is required", MessageBoxButtons.OK, MessageBoxIcon.Error);
					this.textBoxDescription.SelectAll();
					this.textBoxDescription.Focus();
				}
				else
				{
					this.DialogResult = DialogResult.OK;
				}
			}

			public System.Drawing.Image Image
			{
				set
				{
					this.pictureBoxIcon.Image = value;
				}
			}

			public System.String Title
			{
				get
				{
					return this.textBoxTitle.Text.Trim();
				}
				set
				{
					if (value.Trim().Length > 0)
					{
						this.textBoxTitle.Text = value.Trim();
					}
				}
			}

			public System.String Author
			{
				get
				{
					return this.textBoxAuthor.Text.Trim();
				}
				set
				{
					if (value.Trim().Length > 0)
					{
						this.textBoxAuthor.Text = value.Trim();
					}
				}
			}

			public System.String Description
			{
				get
				{
					return this.textBoxDescription.Text.Trim();
				}
				set
				{
					if (value.Trim().Length > 0)
					{
						this.textBoxDescription.Text = value.Trim();
					}
				}
			}

			public System.String Duration
			{
				get
				{
					string selectedDuration = "Forever";
					switch (this.comboBoxDuration.SelectedIndex)
					{
						case 0:
							selectedDuration = "Day";
							break;
						case 1:
							selectedDuration = "Month";
							break;
						default:
							break;
					}
					return selectedDuration;
				}
				set
				{
					if (value.Trim().Length > 0)
					{
						switch (value.Trim())
						{
							case "Day":
								this.comboBoxDuration.SelectedIndex = 0;
								break;
							case "Month":
								this.comboBoxDuration.SelectedIndex = 1;
								break;
							default:
								this.comboBoxDuration.SelectedIndex = 2;
								break;
						}
					}
				}
			}

			public System.Boolean ViewPublishedDocument
			{
				get
				{
					return this.checkBoxViewPublishedDocument.Checked;
				}
				set
				{
					this.checkBoxViewPublishedDocument.Checked = value;
				}
			}
		}

		partial class PublishOnlineForm
		{
			/// <summary>
			/// Required designer variable.
			/// </summary>
			private System.ComponentModel.IContainer components = null;

			/// <summary>
			/// Clean up any resources being used.
			/// </summary>
			/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
			protected override void Dispose(bool disposing)
			{
				if (disposing && (components != null))
				{
					components.Dispose();
				}
				base.Dispose(disposing);
			}

			#region Windows Form Designer generated code

			/// <summary>
			/// Required method for Designer support - do not modify
			/// the contents of this method with the code editor.
			/// </summary>
			private void InitializeComponent()
			{
				System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(PublishOnlineForm));
				this.textBoxTitle = new System.Windows.Forms.TextBox();
				this.labelInstructions = new System.Windows.Forms.Label();
				this.labelTitle = new System.Windows.Forms.Label();
				this.labelDescription = new System.Windows.Forms.Label();
				this.textBoxDescription = new System.Windows.Forms.TextBox();
				this.labelAuthor = new System.Windows.Forms.Label();
				this.textBoxAuthor = new System.Windows.Forms.TextBox();
				this.labelDuration = new System.Windows.Forms.Label();
				this.pictureBoxIcon = new System.Windows.Forms.PictureBox();
				this.buttonOK = new System.Windows.Forms.Button();
				this.buttonCancel = new System.Windows.Forms.Button();
				this.comboBoxDuration = new System.Windows.Forms.ComboBox();
				this.checkBoxViewPublishedDocument = new System.Windows.Forms.CheckBox();
				((System.ComponentModel.ISupportInitialize)(this.pictureBoxIcon)).BeginInit();
				this.SuspendLayout();
				// 
				// textBoxTitle
				// 
				this.textBoxTitle.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
							| System.Windows.Forms.AnchorStyles.Right)));
				this.textBoxTitle.Location = new System.Drawing.Point(107, 79);
				this.textBoxTitle.Name = "textBoxTitle";
				this.textBoxTitle.Size = new System.Drawing.Size(380, 20);
				this.textBoxTitle.TabIndex = 2;
				// 
				// labelInstructions
				// 
				this.labelInstructions.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
							| System.Windows.Forms.AnchorStyles.Right)));
				this.labelInstructions.Location = new System.Drawing.Point(73, 19);
				this.labelInstructions.Name = "labelInstructions";
				this.labelInstructions.Size = new System.Drawing.Size(414, 40);
				this.labelInstructions.TabIndex = 0;
				this.labelInstructions.Text = "Please provide a title, author, description, and duration for the document that you are publishing online.  You may also indicate whether or not you want to view the document online once it has been published.";
				// 
				// labelTitle
				// 
				this.labelTitle.AutoSize = true;
				this.labelTitle.Location = new System.Drawing.Point(12, 82);
				this.labelTitle.Name = "labelTitle";
				this.labelTitle.Size = new System.Drawing.Size(30, 13);
				this.labelTitle.TabIndex = 1;
				this.labelTitle.Text = "&Title:";
				// 
				// labelDescription
				// 
				this.labelDescription.AutoSize = true;
				this.labelDescription.Location = new System.Drawing.Point(12, 150);
				this.labelDescription.Name = "labelDescription";
				this.labelDescription.Size = new System.Drawing.Size(63, 13);
				this.labelDescription.TabIndex = 5;
				this.labelDescription.Text = "&Description:";
				// 
				// textBoxDescription
				// 
				this.textBoxDescription.AcceptsReturn = true;
				this.textBoxDescription.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
							| System.Windows.Forms.AnchorStyles.Right)));
				this.textBoxDescription.Location = new System.Drawing.Point(107, 147);
				this.textBoxDescription.Multiline = true;
				this.textBoxDescription.Name = "textBoxDescription";
				this.textBoxDescription.Size = new System.Drawing.Size(380, 100);
				this.textBoxDescription.TabIndex = 6;
				// 
				// labelAuthor
				// 
				this.labelAuthor.AutoSize = true;
				this.labelAuthor.Location = new System.Drawing.Point(12, 116);
				this.labelAuthor.Name = "labelAuthor";
				this.labelAuthor.Size = new System.Drawing.Size(41, 13);
				this.labelAuthor.TabIndex = 3;
				this.labelAuthor.Text = "&Author:";
				// 
				// textBoxAuthor
				// 
				this.textBoxAuthor.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
							| System.Windows.Forms.AnchorStyles.Right)));
				this.textBoxAuthor.Location = new System.Drawing.Point(107, 113);
				this.textBoxAuthor.Name = "textBoxAuthor";
				this.textBoxAuthor.Size = new System.Drawing.Size(380, 20);
				this.textBoxAuthor.TabIndex = 4;
				// 
				// labelDuration
				// 
				this.labelDuration.AutoSize = true;
				this.labelDuration.Location = new System.Drawing.Point(12, 265);
				this.labelDuration.Name = "labelDuration";
				this.labelDuration.Size = new System.Drawing.Size(50, 13);
				this.labelDuration.TabIndex = 7;
				this.labelDuration.Text = "Du&ration:";
				// 
				// pictureBoxIcon
				// 
				this.pictureBoxIcon.Location = new System.Drawing.Point(23, 23);
				this.pictureBoxIcon.Name = "pictureBoxIcon";
				this.pictureBoxIcon.Size = new System.Drawing.Size(32, 32);
				this.pictureBoxIcon.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize;
				this.pictureBoxIcon.TabIndex = 11;
				this.pictureBoxIcon.TabStop = false;
				// 
				// buttonOK
				// 
				this.buttonOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
				this.buttonOK.DialogResult = System.Windows.Forms.DialogResult.OK;
				this.buttonOK.Location = new System.Drawing.Point(331, 337);
				this.buttonOK.Name = "buttonOK";
				this.buttonOK.Size = new System.Drawing.Size(75, 23);
				this.buttonOK.TabIndex = 10;
				this.buttonOK.Text = "OK";
				this.buttonOK.UseVisualStyleBackColor = true;
				this.buttonOK.Click += new System.EventHandler(this.buttonOK_Click);
				// 
				// buttonCancel
				// 
				this.buttonCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
				this.buttonCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
				this.buttonCancel.Location = new System.Drawing.Point(412, 337);
				this.buttonCancel.Name = "buttonCancel";
				this.buttonCancel.Size = new System.Drawing.Size(75, 23);
				this.buttonCancel.TabIndex = 11;
				this.buttonCancel.Text = "Cancel";
				this.buttonCancel.UseVisualStyleBackColor = true;
				// 
				// comboBoxDuration
				// 
				this.comboBoxDuration.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
							| System.Windows.Forms.AnchorStyles.Right)));
				this.comboBoxDuration.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
				this.comboBoxDuration.FormattingEnabled = true;
				this.comboBoxDuration.Items.AddRange(new object[] {
            "Automatically remove the document after one day",
            "Automatically remove the document after one month",
            "Publish as a permanent document"});
				this.comboBoxDuration.Location = new System.Drawing.Point(107, 262);
				this.comboBoxDuration.Name = "comboBoxDuration";
				this.comboBoxDuration.Size = new System.Drawing.Size(380, 21);
				this.comboBoxDuration.TabIndex = 8;
				// 
				// checkBoxViewPublishedDocument
				// 
				this.checkBoxViewPublishedDocument.AutoSize = true;
				this.checkBoxViewPublishedDocument.Location = new System.Drawing.Point(107, 299);
				this.checkBoxViewPublishedDocument.Name = "checkBoxViewPublishedDocument";
				this.checkBoxViewPublishedDocument.Size = new System.Drawing.Size(241, 17);
				this.checkBoxViewPublishedDocument.TabIndex = 9;
				this.checkBoxViewPublishedDocument.Text = "&View the document once it is published online";
				this.checkBoxViewPublishedDocument.UseVisualStyleBackColor = true;
				// 
				// PublishOnlineForm
				// 
				this.AcceptButton = this.buttonOK;
				this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
				this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
				this.CancelButton = this.buttonCancel;
				this.ClientSize = new System.Drawing.Size(499, 372);
				this.ControlBox = false;
				this.Controls.Add(this.checkBoxViewPublishedDocument);
				this.Controls.Add(this.comboBoxDuration);
				this.Controls.Add(this.buttonCancel);
				this.Controls.Add(this.buttonOK);
				this.Controls.Add(this.pictureBoxIcon);
				this.Controls.Add(this.labelDuration);
				this.Controls.Add(this.labelAuthor);
				this.Controls.Add(this.textBoxAuthor);
				this.Controls.Add(this.labelDescription);
				this.Controls.Add(this.textBoxDescription);
				this.Controls.Add(this.labelTitle);
				this.Controls.Add(this.labelInstructions);
				this.Controls.Add(this.textBoxTitle);
				this.MaximizeBox = false;
				this.MinimizeBox = false;
				this.Name = "PublishOnlineForm";
				this.ShowIcon = false;
				this.ShowInTaskbar = false;
				this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Hide;
				this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
				this.Text = "Publish Online";
				((System.ComponentModel.ISupportInitialize)(this.pictureBoxIcon)).EndInit();
				this.ResumeLayout(false);
				this.PerformLayout();

			}

			#endregion

			private System.Windows.Forms.TextBox textBoxTitle;
			private System.Windows.Forms.Label labelInstructions;
			private System.Windows.Forms.Label labelTitle;
			private System.Windows.Forms.Label labelDescription;
			private System.Windows.Forms.TextBox textBoxDescription;
			private System.Windows.Forms.Label labelAuthor;
			private System.Windows.Forms.TextBox textBoxAuthor;
			private System.Windows.Forms.Label labelDuration;
			private System.Windows.Forms.PictureBox pictureBoxIcon;
			private System.Windows.Forms.Button buttonOK;
			private System.Windows.Forms.Button buttonCancel;
			private System.Windows.Forms.ComboBox comboBoxDuration;
			private System.Windows.Forms.CheckBox checkBoxViewPublishedDocument;
		}
	}
}
'@
if (-not ('Addon.PublishOnline.PublishOnlineForm' -as [System.Type])) {
	Add-Type -ReferencedAssemblies 'System.Windows.Forms','System.Drawing' -TypeDefinition $publishOnlineDialogCode
}

#endregion

#region define Web Browser window

if (-not ('Addon.PublishOnline.WebBrowserWindow' -as [System.Type])) {
	$cSharpCode = @'
using System;
using System.Linq;
using System.Windows.Forms;
using ActiproSoftware.UIStudio.Dock;
using Quest.PowerGUI.SDK;
using ToolWindow = Quest.PowerGUI.SDK.ToolWindow;

namespace Addon.PublishOnline
{
    public class WebBrowserWindow
    {
        private const string PoshCodeKey = "PoshCode";

        private readonly ToolWindow _poshWindow;

        public WebBrowserWindow()
        {
            var editor = ScriptEditorFactory.CurrentInstance;
            _poshWindow = editor.ToolWindows[PoshCodeKey] ?? editor.ToolWindows.Add(PoshCodeKey);
            _poshWindow.Visible = false;
            _poshWindow.Title = PoshCodeKey;
            if (!(_poshWindow.Control is WebBrowser))
            {
                var webBrowser = new WebBrowser();
                webBrowser.DocumentCompleted += (sender, args) => Activate();
                _poshWindow.Control = webBrowser;
                
            }
            editor.Invoke((Action)(() =>_poshWindow.Control.Parent.GetType().GetProperty("State").SetValue(_poshWindow.Control.Parent, ToolWindowState.TabbedDocument, null)));
        }

        public void Navigate(string url)
        {
            var webBrowser = _poshWindow.Control as WebBrowser;
            if (webBrowser == null)
            {
                return;
            }            
			webBrowser.Navigate(url);
        }

        public void Activate()
        {
            ScriptEditorFactory.CurrentInstance.Invoke((Action)(() =>
            {
                _poshWindow.Visible = true;
                var m = _poshWindow.Control.Parent.GetType() .GetMethods().First(it => it.Name == "Activate" && it.GetParameters().Count() == 1);
                m.Invoke(_poshWindow.Control.Parent, new object[] {true});
            }));
        }
    }
}	
'@

$refs = @(	"System.Windows.Forms",
			"System.Core",
			"System.Drawing",			
			"$PGHome\SDK.dll", 
			"$PGHome\ActiproSoftware.UIStudio.Dock.Net20.dll",
			"$PGHome\ActiproSoftware.WinUICore.Net20.dll",
			"$PGHome\ActiproSoftware.Shared.Net20.dll",
			"$PGHome\ActiproSoftware.SyntaxEditor.Net20.dll")			

Add-Type -ReferencedAssemblies $refs -IgnoreWarnings -TypeDefinition $cSharpCode | Out-Null	
}

#endregion

#region init Web Browser window 
	$webBrowserWindow = New-Object -TypeName 'Addon.PublishOnline.WebBrowserWindow'
#endregion

#region Create the Publish Online command.

if (-not ($publishOnlineCommand = $se.Commands['FileCommand.PublishOnline'])) {
	$publishOnlineCommand = New-Object Quest.PowerGUI.SDK.ItemCommand('FileCommand', 'PublishOnline')
	$publishOnlineCommand.Text = 'P&ublish Online...'
	$publishOnlineCommand.Image = $imageLibrary['PublishOnlineImage16']
	$publishOnlineCommand.AddShortcut('Ctrl+U')
	$publishOnlineCommand.ScriptBlock = {
		function Publish-PoshCodeDocument {
			[CmdletBinding()]
			param(
				[Parameter(Mandatory=$true)]
				[ValidateNotNullOrEmpty()]
				[System.String]
				$Title,

				[Parameter(Mandatory=$true)]
				[ValidateNotNullOrEmpty()]
				[System.String]
				$Description = 'This file was uploaded by a PowerGUI Script Editor Add-on.',

				[Parameter(Mandatory=$true)]
				[ValidateSet('Day','Month','Forever')]
				[System.String]
				$Duration = 'Forever',

				[Parameter(Mandatory=$true)]
				[ValidateNotNullOrEmpty()]
				[System.String]
				$Author = 'Anonymous',

				[Parameter(Mandatory=$true)]
				[ValidateNotNullOrEmpty()]
				[System.String]
				$Script
			)
			[Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
			[string]$data = $null
			[string]$meta = $null

			$meta = 'format=' + [System.Web.HttpUtility]::UrlEncode('posh')

			if ($Duration -eq 'Day') {
				$meta += '&expiry=d'
			} elseif ($Duration -eq 'Month') {
				$meta += '&expiry=m'
			} else {
				$meta += '&expiry=f'
			}

			if($Description) {
				$meta += '&descrip=' + [System.Web.HttpUtility]::UrlEncode($Description)
			} else {
				$meta += '&descrip='
			}   
			$meta += '&poster=' + [System.Web.HttpUtility]::UrlEncode($Author)

			$meta += '&paste=Send&posttitle=' + [System.Web.HttpUtility]::UrlEncode($Title)

			$data = $meta + '&code2=' + [System.Web.HttpUtility]::UrlEncode($Script)

			$request = [System.Net.WebRequest]::Create('http://PoshCode.org/')
			$request.Credentials = [System.Net.CredentialCache]::DefaultCredentials
			if($request.Proxy -ne $null) {
				$request.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
			}
			$request.ContentType = 'application/x-www-form-urlencoded'
			$request.ContentLength = $data.Length
			$request.Method = 'POST'

			$post = New-Object System.IO.StreamWriter $request.GetRequestStream()
			$post.Write($data)
			$post.Flush()
			$post.Close()

			Write-Output $request.GetResponse().ResponseUri.AbsoluteUri
			$request.Abort()
		}

		$se = [Quest.PowerGUI.SDK.ScriptEditorFactory]::CurrentInstance
		$document = $se.CurrentDocumentWindow
		if ($document.Document.Lines.Count -le 1) {
			[System.Windows.Forms.MessageBox]::Show("Your ""$($se.CurrentDocumentWindow.Title)"" document cannot be published online because it contains less than 2 lines of script.$([System.Environment]::NewLine *2)Add more content to your document and try again.","Error while publishing document",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
			return
		}
		if (-not $document.Document.IsSaved) {
			$se.Commands['FileCommand.Save'].InvokeAsync()
		}
		if ($document.Document.IsSaved) {
			$configPath = "${PSScriptRoot}\PublishOnline.config.xml"
			$defaultTitle = $document.Title
			$defaultDescription = 'This file was uploaded by a PowerGUI Script Editor Add-on.'
			$defaultDuration = 'Forever'
			$defaultAuthor = 'Anonymous'
			$defaultViewPublishedDocument = $true
			if (Test-Path -LiteralPath $configPath) {
				$configuration = Import-Clixml -Path $configPath
				if ($configuration.ContainsKey($document.Title)) {
					$defaultTitle = $configuration[$document.Title].Title
					$defaultDescription = $configuration[$document.Title].Description
					$defaultDuration = $configuration[$document.Title].Duration
					$defaultAuthor = $configuration[$document.Title].Author
				} else {
					$defaultAuthor = $configuration.Default.Author
				}
				$defaultViewPublishedDocument = $configuration.Default.ViewPublishedDocument
			}
			$publishOnlineDialog = New-Object -TypeName Addon.PublishOnline.PublishOnlineForm
			$publishOnlineDialog.Image = $imageLibrary['PublishOnlineImage32']
			$publishOnlineDialog.Title = $defaultTitle
			$publishOnlineDialog.Author = $defaultAuthor
			$publishOnlineDialog.Description = $defaultDescription
			$publishOnlineDialog.Duration = $defaultDuration
			$publishOnlineDialog.ViewPublishedDocument = $defaultViewPublishedDocument
			$result = $publishOnlineDialog.ShowDialog()
			if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
				$title = $publishOnlineDialog.Title
				$author = $publishOnlineDialog.Author
				$description = $publishOnlineDialog.Description
				$duration = $publishOnlineDialog.Duration
				$viewPublishedDocument = $publishOnlineDialog.ViewPublishedDocument
				if (-not (Get-Variable -Name configuration)) {
					$configuration = @{}
				}
				$configuration[$document.Title] = @{
					      'Title' = $title
					     'Author' = $author
					'Description' = $description
					   'Duration' = $duration
				}
				$configuration['Default'] = @{
						           'Author' = $author
					'ViewPublishedDocument' = $viewPublishedDocument
				}
				Export-Clixml -InputObject $configuration -Path $configPath
				$documentUrl = Publish-PoshCodeDocument -Title $title -Description $description -Duration $duration -Author $author -Script $document.Document.Text
				if ($documentUrl -ne 'http://poshcode.org/') {
					Write-Host "Document $($document.Title) has been published at $documentUrl"
					if ($viewPublishedDocument) {
						$webBrowserWindow.Navigate($documentUrl)
						if (-not ($poshCodeCommand = $se.Commands['GoCommand.PoshCode'])) {
							$poshCodeCommand = New-Object Quest.PowerGUI.SDK.ItemCommand('GoCommand', 'PoshCode')
							$poshCodeCommand.Text = 'Po&shCode'
							$poshCodeCommand.Image = $imageLibrary['PublishOnlineImage16']
							if ($goMenu = $se.Menus['MenuBar.Go']) {
								$index = $goMenu.Items.Count + 1
								if ($index -le 9) {
									$poshCodeCommand.AddShortcut("Ctrl+${index}")
								}
							}
							$poshCodeCommand.ScriptBlock = {
								$webBrowserWindow.Activate()								
							}
							$se.Commands.Add($poshCodeCommand)
							if ($goMenu -and (-not ($goMenu.Items['GoCommand.PoshCode']))) {
								$goMenu.Items.Add($poshCodeCommand)
							}
						}
						
					}
				}
			}
		}
	}

	$se.Commands.Add($publishOnlineCommand)
}

#endregion

#region Create the Publish to PoshCode menu item in the File menu.

if (($fileMenu = $se.Menus['MenuBar.File']) -and
    (-not $fileMenu.Items['FileCommand.PublishOnline'])) {
	if ($searchOnlineMenuItem = $fileMenu.Items['FileCommand.SearchOnline']) {
		$index = $fileMenu.Items.IndexOf($searchOnlineMenuItem)
		$fileMenu.Items.Insert($index + 1, $publishOnlineCommand)
	} else {
		$fileMenu.Items.Add($publishOnlineCommand)
	}
}

#endregion

#region Clean-up the Add-on when it is removed.

$ExecutionContext.SessionState.Module.OnRemove = {
	$se = [Quest.PowerGUI.SDK.ScriptEditorFactory]::CurrentInstance

	#region Remove the PoshCode window and the associated Go command/menu item if they exist.

	if ($poshCodeWindow = $se.ToolWindows['PoshCode']) {
		if (($goMenu = $se.Menus['MenuBar.Go']) -and
		    ($poshCodeMenuItem = $goMenu.Items['GoCommand.PoshCode'])) {
			$goMenu.Items.Remove($poshCodeMenuItem) | Out-Null
		}
		if ($poshCodeCommand = $se.Commands['GoCommand.PoshCode']) {
			$se.Commands.Remove($poshCodeCommand) | Out-Null
		}
		$se.ToolWindows.Remove($poshCodeWindow) | Out-Null
	}

	#endregion

	#region Remove the Publish Online menu item.

	if (($fileMenu = $se.Menus['MenuBar.File']) -and
	    ($publishOnlineMenuItem = $fileMenu.Items['FileCommand.PublishOnline'])) {
		$fileMenu.Items.Remove($publishOnlineMenuItem) | Out-Null
	}

	#endregion

	#region Remove the Publish Online command.

	if ($publishOnlineCommand = $se.Commands['FileCommand.PublishOnline']) {
		$se.Commands.Remove($publishOnlineCommand) | Out-Null
	}

	#endregion
}

#endregion

# SIG # Begin signature block
# MIId3wYJKoZIhvcNAQcCoIId0DCCHcwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUsHXnq2ofrbrj6Wl/lvo9fzpe
# w2OgghjPMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggTTMIIDu6ADAgECAhAY2tGeJn3ou0ohWM3MaztKMA0GCSqGSIb3DQEBBQUAMIHK
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsT
# FlZlcmlTaWduIFRydXN0IE5ldHdvcmsxOjA4BgNVBAsTMShjKSAyMDA2IFZlcmlT
# aWduLCBJbmMuIC0gRm9yIGF1dGhvcml6ZWQgdXNlIG9ubHkxRTBDBgNVBAMTPFZl
# cmlTaWduIENsYXNzIDMgUHVibGljIFByaW1hcnkgQ2VydGlmaWNhdGlvbiBBdXRo
# b3JpdHkgLSBHNTAeFw0wNjExMDgwMDAwMDBaFw0zNjA3MTYyMzU5NTlaMIHKMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZl
# cmlTaWduIFRydXN0IE5ldHdvcmsxOjA4BgNVBAsTMShjKSAyMDA2IFZlcmlTaWdu
# LCBJbmMuIC0gRm9yIGF1dGhvcml6ZWQgdXNlIG9ubHkxRTBDBgNVBAMTPFZlcmlT
# aWduIENsYXNzIDMgUHVibGljIFByaW1hcnkgQ2VydGlmaWNhdGlvbiBBdXRob3Jp
# dHkgLSBHNTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK8kCAgpejWe
# YAyq50s7Ttx8vDxFHLsr4P4pAvlXCKNkhRUn9fGtyDGJXSLoKqqmQrOP+LlVt7G3
# S7P+j34HV+zvQ9tmYhVhz2ANpNje+ODDYgg9VBPrScpZVIUm5SuPG5/r9aGRwjNJ
# 2ENjalJL0o/ocFFN0Ylpe8dw9rPcEnTbe11LVtOWvxV3obD0oiXyrxySZxjl9AYE
# 75C55ADk3Tq1Gf8CuvQ87uCL6zeL7PTXrPL28D2v3XWRMxkdHEDLdCQZIZPZFP6s
# KlLHj9UESeSNY0eIPGmDy/5HvSt+T8WVrg6d1NFDwGdz4xQIfuU/n3O4MwrPXT80
# h5aK7lPoJRUCAwEAAaOBsjCBrzAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQE
# AwIBBjBtBggrBgEFBQcBDARhMF+hXaBbMFkwVzBVFglpbWFnZS9naWYwITAfMAcG
# BSsOAwIaBBSP5dMahqyNjmvDz4Bq1EgYLHsZLjAlFiNodHRwOi8vbG9nby52ZXJp
# c2lnbi5jb20vdnNsb2dvLmdpZjAdBgNVHQ4EFgQUf9Nlp8Ld7LvwMAnzQzn6Aq8z
# MTMwDQYJKoZIhvcNAQEFBQADggEBAJMkSjBfYs/YGpgvPercmS29d/aleSI47MSn
# oHgSrWIORXBkxeeXZi2YCX5fr9bMKGXyAaoIGkfe+fl8kloIaSAN2T5tbjwNbtjm
# BpFAGLn4we3f20Gq4JYgyc1kFTiByZTuooQpCxNvjtsM3SUC26SLGUTSQXoFaUpY
# T2DKfoJqCwKqJRc5tdt/54RlKpWKvYbeXoEWgy0QzN79qIIqbSgfDQvE5ecaJhnh
# 9BFvELWV/OdCBTLbzp1RXii2noXTW++lfUVAco63DmsOBvszNUhxuJ0ni8RlXw2G
# dpxEevaVXPZdMggzpFS2GD9oXPJCSoU4VINf0egs8qwR1qjtY2owggVNMIIENaAD
# AgECAhAC5D+LDsdLzyijrO9Fle9rMA0GCSqGSIb3DQEBBQUAMIG0MQswCQYDVQQG
# EwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWdu
# IFRydXN0IE5ldHdvcmsxOzA5BgNVBAsTMlRlcm1zIG9mIHVzZSBhdCBodHRwczov
# L3d3dy52ZXJpc2lnbi5jb20vcnBhIChjKTEwMS4wLAYDVQQDEyVWZXJpU2lnbiBD
# bGFzcyAzIENvZGUgU2lnbmluZyAyMDEwIENBMB4XDTEzMDQzMDAwMDAwMFoXDTE2
# MDQyOTIzNTk1OVowgZAxCzAJBgNVBAYTAlVTMQ4wDAYDVQQIEwVUZXhhczETMBEG
# A1UEBxMKUm91bmQgUm9jazENMAsGA1UEChQERGVsbDE+MDwGA1UECxM1RGlnaXRh
# bCBJRCBDbGFzcyAzIC0gTWljcm9zb2Z0IFNvZnR3YXJlIFZhbGlkYXRpb24gdjIx
# DTALBgNVBAMUBERlbGwwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDW
# Ieq0GYblhkMmx6Gq4kLDd2SSARqrs3yZgYLNAmvre9Q5WiLId5+voSFQfPehaAI4
# mqZiJp8XI6gP0L0Duhh3PpAptPA4KeZ715Ht2eloIESEnrZIcSQ3Q/dQDvcVIMuO
# 8JVAnNfyJ2B2wrJ1869thum7P8Zi8fmRnRBz9uVscusHiFuVaILUz1bU8uHb5y0E
# bcIfv8AcNYnkBo4R2uP4e5dzsiSKKJRjshv+EgISz0UEWipevIp3oUZtNtkUdyLd
# lZuzV0HlnMlV0XQwUIK7usRqn+Qk4iJlxQz7oTzZmNDYXcANyZ6TJgN+4Nog3tGo
# 0F75wktouny7cXuOe0U1AgMBAAGjggF7MIIBdzAJBgNVHRMEAjAAMA4GA1UdDwEB
# /wQEAwIHgDBABgNVHR8EOTA3MDWgM6Axhi9odHRwOi8vY3NjMy0yMDEwLWNybC52
# ZXJpc2lnbi5jb20vQ1NDMy0yMDEwLmNybDBEBgNVHSAEPTA7MDkGC2CGSAGG+EUB
# BxcDMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LnZlcmlzaWduLmNvbS9ycGEw
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwcQYIKwYBBQUHAQEEZTBjMCQGCCsGAQUFBzAB
# hhhodHRwOi8vb2NzcC52ZXJpc2lnbi5jb20wOwYIKwYBBQUHMAKGL2h0dHA6Ly9j
# c2MzLTIwMTAtYWlhLnZlcmlzaWduLmNvbS9DU0MzLTIwMTAuY2VyMB8GA1UdIwQY
# MBaAFM+Zqep7JvRLyY6P1/AFJu/j0qedMBEGCWCGSAGG+EIBAQQEAwIEEDAWBgor
# BgEEAYI3AgEbBAgwBgEBAAEB/zANBgkqhkiG9w0BAQUFAAOCAQEAEJ0v1F+Zh4IF
# C9vIYhqVUIQHHyfGsSVAisS09ZyDFPGpL/tqn+afeNURZ6rePlWpZpnr+7ILgx6M
# sEREKEWowDe5O7I6OyD9OnDjYxZDYVEMTWCxRDp42+qvxtEtKpU2WKUaqsAgQjlp
# hoOr9PJsnn5VNyT78WriKoJlYp0g4diiHkFqk+PUngqZT3mcd/0e2VjNH0kwXgnd
# PXtYOMHq/X+UKdNd4XEwSrh/7bdTrczR8pwxs3xaBYH259832aiz7/KdHE4ZcW6w
# 9OX/ZFOavlO2Ij8TyhYaH6su8eA4YTMJlK3W4PEYxXPzJvKY8KYm3bJzu+4jQgHM
# E4FE6vYFcDCCBgowggTyoAMCAQICEFIA5aolVvwahu2WydRLM8cwDQYJKoZIhvcN
# AQEFBQAwgcoxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5jLjEf
# MB0GA1UECxMWVmVyaVNpZ24gVHJ1c3QgTmV0d29yazE6MDgGA1UECxMxKGMpIDIw
# MDYgVmVyaVNpZ24sIEluYy4gLSBGb3IgYXV0aG9yaXplZCB1c2Ugb25seTFFMEMG
# A1UEAxM8VmVyaVNpZ24gQ2xhc3MgMyBQdWJsaWMgUHJpbWFyeSBDZXJ0aWZpY2F0
# aW9uIEF1dGhvcml0eSAtIEc1MB4XDTEwMDIwODAwMDAwMFoXDTIwMDIwNzIzNTk1
# OVowgbQxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5jLjEfMB0G
# A1UECxMWVmVyaVNpZ24gVHJ1c3QgTmV0d29yazE7MDkGA1UECxMyVGVybXMgb2Yg
# dXNlIGF0IGh0dHBzOi8vd3d3LnZlcmlzaWduLmNvbS9ycGEgKGMpMTAxLjAsBgNV
# BAMTJVZlcmlTaWduIENsYXNzIDMgQ29kZSBTaWduaW5nIDIwMTAgQ0EwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD1I0tepdeKuzLp1Ff37+THJn6tGZj+
# qJ19lPY2axDXdYEwfwRof8srdR7NHQiM32mUpzejnHuA4Jnh7jdNX847FO6G1ND1
# JzW8JQs4p4xjnRejCKWrsPvNamKCTNUh2hvZ8eOEO4oqT4VbkAFPyad2EH8nA3y+
# rn59wd35BbwbSJxp58CkPDxBAD7fluXF5JRx1lUBxwAmSkA8taEmqQynbYCOkCV7
# z78/HOsvlvrlh3fGtVayejtUMFMb32I0/x7R9FqTKIXlTBdOflv9pJOZf9/N76R1
# 7+8V9kfn+Bly2C40Gqa0p0x+vbtPDD1X8TDWpjaO1oB21xkupc1+NC2JAgMBAAGj
# ggH+MIIB+jASBgNVHRMBAf8ECDAGAQH/AgEAMHAGA1UdIARpMGcwZQYLYIZIAYb4
# RQEHFwMwVjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL2Nw
# czAqBggrBgEFBQcCAjAeGhxodHRwczovL3d3dy52ZXJpc2lnbi5jb20vcnBhMA4G
# A1UdDwEB/wQEAwIBBjBtBggrBgEFBQcBDARhMF+hXaBbMFkwVzBVFglpbWFnZS9n
# aWYwITAfMAcGBSsOAwIaBBSP5dMahqyNjmvDz4Bq1EgYLHsZLjAlFiNodHRwOi8v
# bG9nby52ZXJpc2lnbi5jb20vdnNsb2dvLmdpZjA0BgNVHR8ELTArMCmgJ6AlhiNo
# dHRwOi8vY3JsLnZlcmlzaWduLmNvbS9wY2EzLWc1LmNybDA0BggrBgEFBQcBAQQo
# MCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLnZlcmlzaWduLmNvbTAdBgNVHSUE
# FjAUBggrBgEFBQcDAgYIKwYBBQUHAwMwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMT
# EFZlcmlTaWduTVBLSS0yLTgwHQYDVR0OBBYEFM+Zqep7JvRLyY6P1/AFJu/j0qed
# MB8GA1UdIwQYMBaAFH/TZafC3ey78DAJ80M5+gKvMzEzMA0GCSqGSIb3DQEBBQUA
# A4IBAQBWIuY0pMRhy0i5Aa1WqGQP2YyRxLvMDOWteqAif99HOEotbNF/cRp87HCp
# sfBP5A8MU/oVXv50mEkkhYEmHJEUR7BMY4y7oTTUxkXoDYUmcwPQqYxkbdxxkuZF
# BWAVWVE5/FgUa/7UpO15awgMQXLnNyIGCb4j6T9Emh7pYZ3MsZBc/D3SjaxCPWU2
# 1LQ9QCiPmxDPIybMSyDLkB9djEw0yjzY5TfWb6UgvTTrJtmuDefFmvehtCGRM2+G
# 6Fi7JXx0Dlj+dRtjP84xfJuPG5aexVN2hFucrZH6rO2Tul3IIVPCglNjrxINUIcR
# Gz1UUpaKLJw9khoImgUux5OlSJHTMYIEejCCBHYCAQEwgckwgbQxCzAJBgNVBAYT
# AlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5jLjEfMB0GA1UECxMWVmVyaVNpZ24g
# VHJ1c3QgTmV0d29yazE7MDkGA1UECxMyVGVybXMgb2YgdXNlIGF0IGh0dHBzOi8v
# d3d3LnZlcmlzaWduLmNvbS9ycGEgKGMpMTAxLjAsBgNVBAMTJVZlcmlTaWduIENs
# YXNzIDMgQ29kZSBTaWduaW5nIDIwMTAgQ0ECEALkP4sOx0vPKKOs70WV72swCQYF
# Kw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkD
# MQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJ
# KoZIhvcNAQkEMRYEFNJHV+0yhMyOwG4k3nNs8ZIGQOMPMA0GCSqGSIb3DQEBAQUA
# BIIBAIzWHlDARUFm5X8Zg7ihdb1Ap/eTfJW3C697eRN/lpV1WYM102cvseuhzxJv
# KzYz9NQUABs521qPL0eiu3xO+e3Y42auMKlaskiEW3coE414YnqDRdS4GYi3WlQL
# FLqY48jVVupQEiJt715akw3prYlyYAlkdDZjIjfjDHcSA5B9ScT5UICROqrp/TF/
# AQXvnl0kk4iN487DbyyfsBEbuLN/xNjBTRbJlaeIoVdeyHTuhqx1Do0YTZpEop5l
# nxUk6dXUVi2bIb15fg2Ub6qNiZCtJDqKl9bE3SRwpv5fELoc7oinQjLYyMs5WZGf
# w5AFcP7eFRWSbgGDsYXbJjNeWmGhggILMIICBwYJKoZIhvcNAQkGMYIB+DCCAfQC
# AQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRp
# b24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0Eg
# LSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkD
# MQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTMwNjI2MTQ0OTQxWjAjBgkq
# hkiG9w0BCQQxFgQU0S0nb4cgZr5ePpywMRA0jMSov4cwDQYJKoZIhvcNAQEBBQAE
# ggEAfbkNNwipX+nl4yDjHsJS0RWqsT6wY87A4/Q8nQD5+vIWOyN6qpDgW15JJRmM
# 1CwBWby1i7wbu755+wi7L9rZUqqNv+QFZuH3r4gAXtzBVB5xRd6SRe+sWjMaf50F
# S4dmyF52sErK63sQlixqO7uzIdxmOtvIYrU9cEDJvihyYwa1UI9pMEvmdVxGjUp0
# ogVbNhsmccNi+Sa3mf8AKwsAcWGyDkrs6SKNg3fqLCMJKiWuvJx0G3RmZdlcdrWf
# E4wszTp23Ud1UZPANX660F3oQRhWt6PTloRYmhxjtCzE9LW4qvvEIXfXkkUcsozl
# CtUUdAVw0dMXvMKKJRB5UpIB+g==
# SIG # End signature block

