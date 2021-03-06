Import-Module : Process should have elevated status to access IIS configuration data.
At C:\Users\ca27573\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1:18 char:29
+ Get-Module -ListAvailable | Import-Module
+                             ~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (:) [Import-Module], InvalidOperationException
    + FullyQualifiedErrorId : Module_ImportModuleError,Microsoft.PowerShell.Commands.ImportModuleCommand


PSVersion Name
--------- ----
3.0       Microsoft.PowerShell.Core
1.0       Microsoft.EnterpriseManagement.OperationsManager.Client
2.0       VMware.VimAutomation.Core
1.0       Microsoft.Exchange.Management.PowerShell.E2010
1.0       Microsoft.Exchange.Management.Powershell.Support
1.0       Quest.ActiveRoles.ADManagement
2.0       VMware.DeployAutomation
2.0       VMware.ImageBuilder
2.0       VMware.VimAutomation.License



ModuleType Name
---------- ----
  Manifest ActiveDirectory
  Manifest AppLocker
    Script BackcompatCmdlets
  Manifest BitsTransfer
    Script BSonPosh
    Binary CimCmdlets
  Manifest GroupPolicy
    Script ISE
  Manifest Lync
  Manifest Microsoft.PowerShell.Diagnostics
  Manifest Microsoft.PowerShell.Host
  Manifest Microsoft.PowerShell.Management
  Manifest Microsoft.PowerShell.Security
  Manifest Microsoft.PowerShell.Utility
  Manifest Microsoft.WSMan.Management
    Script MyTools
    Script PSDiagnostics
    Binary PSScheduledJob
    Script PSTerminalServices
  Manifest PSWorkflow
  Manifest PSWorkflowUtility
    Script SetCsPinSendCAWelcomeMail
    Script startup
  Manifest TroubleshootingPack
  Manifest WebAdministration


To list all cmdlets from a specific module use PS:> Get-Command -Module <Name>

          Welcome to the VMware vSphere PowerCLI!

Log in to a vCenter Server or ESX host:              Connect-VIServer
To find out what commands are available, type:       Get-VICommand
To show searchable help for all PowerCLI commands:   Get-PowerCLIHelp
Once you've connected, display all virtual machines: Get-VM
If you need more help, visit the PowerCLI community: Get-PowerCLICommunity

       Copyright (C) 1998-2012 VMware, Inc. All rights reserved.



Loading custom functions library.

