## UI Automation v 1.6 -- REQUIRES the Reflection module (current version: http://poshcode.org/2480 )
## 
# WASP 2.0 is getting closer, but this is just a preview:
# -- a lot of the commands have weird names still because they're being generated ignorantly
# -- eg: Invoke-Toggle.Toggle and  Invoke-Invoke.Invoke


#                                                                                                   #
# Select-Window Notepad | Remove-Window -passthru                                                   #
# ## And later ...                                                                                  #
# Select-Window Notepad | Select-ChildWindow | Send-Keys "%N"                                       #
# ## OR ##                                                                                          #
# Select-Window Notepad | Select-ChildWindow |                                                      #
#    Select-Control -title "Do&n't Save" -recurse | Send-Click                                      #
#                                                                                                   #

#                                                                                                   #
# PS notepad | Select-Window | Select-ChildWindow | %{ New-Object Huddled.Wasp.Window $_ }          #
#                                                                                                   #


# cp C:\Users\Joel\Projects\PowerShell\Wasp\trunk\WASP\bin\Debug\Wasp.dll .\Modules\WASP\           #
# Import-Module WASP


#PS1 [Reflection.Assembly]::Load()
#PS1 [Reflection.Assembly]::Load()

Add-Type -AssemblyName "UIAutomationClient, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
Add-Type -AssemblyName "UIAutomationTypes, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"

$SWA = "System.Windows.Automation"
#  Add-Accelerator InvokePattern      "$SWA.InvokePattern"                -EA SilentlyContinue
#  Add-Accelerator ExpandPattern      "$SWA.ExpandCollapsePattern"        -EA SilentlyContinue
#  Add-Accelerator WindowPattern      "$SWA.WindowPattern"                -EA SilentlyContinue
#  Add-Accelerator TransformPattern   "$SWA.TransformPattern"             -EA SilentlyContinue
#  Add-Accelerator ValuePattern       "$SWA.ValuePattern"                 -EA SilentlyContinue
#  Add-Accelerator TextPattern        "$SWA.TextPattern"                  -EA SilentlyContinue

# This is what requires the Reflection module:
Add-Accelerator Automation         "$SWA.Automation"                   -EA SilentlyContinue
Add-Accelerator AutomationElement  "$SWA.AutomationElement"            -EA SilentlyContinue
Add-Accelerator TextRange          "$SWA.Text.TextPatternRange"        -EA SilentlyContinue
#####  Conditions
Add-Accelerator Condition          "$SWA.Condition"                    -EA SilentlyContinue
Add-Accelerator AndCondition       "$SWA.AndCondition"                 -EA SilentlyContinue
Add-Accelerator OrCondition        "$SWA.OrCondition"                  -EA SilentlyContinue
Add-Accelerator NotCondition       "$SWA.NotCondition"                 -EA SilentlyContinue
Add-Accelerator PropertyCondition  "$SWA.PropertyCondition"            -EA SilentlyContinue
#####  IDentifiers
Add-Accelerator AutoElementIds     "$SWA.AutomationElementIdentifiers" -EA SilentlyContinue
Add-Accelerator TransformIds       "$SWA.TransformPatternIdentifiers"  -EA SilentlyContinue

##### Patterns:
$patterns = Get-Type -Assembly UIAutomationClient -Base System.Windows.Automation.BasePattern 
            #| Where { $_ -ne [System.Windows.Automation.InvokePattern] }

Add-Type -TypeDefinition @"
using System;
using System.ComponentModel;
using System.Management.Automation;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Windows.Automation;

[AttributeUsage(AttributeTargets.Field | AttributeTargets.Property)]
public class StaticFieldAttribute : ArgumentTransformationAttribute {
   private Type _class;

   public override string ToString() {
      return string.Format("[StaticField(OfClass='{0}')]", OfClass.FullName);
   }

   public override Object Transform( EngineIntrinsics engineIntrinsics, Object inputData) {
      if(inputData is string && !string.IsNullOrEmpty(inputData as string)) {
         System.Reflection.FieldInfo field = _class.GetField(inputData as string, BindingFlags.Static | BindingFlags.Public);
         if(field != null) {
            return field.GetValue(null);
         }
      }
      return inputData;
   }
   
   public StaticFieldAttribute( Type ofClass ) {
      OfClass = ofClass;
   }

   public Type OfClass {
      get { return _class; }
      set { _class = value; }
   }   
}

public class UIAutomationHelper {
   public static AutomationElement RootElement {
      get { return AutomationElement.RootElement; }
   }
}

"@ -ReferencedAssemblies UIAutomationClient, UIAutomationTypes
            
            
            
## TODO: Write Get-SupportedPatterns or rather ... 
## Get-SupportedFunctions (to return the names of the functions for the supported patterns)
## TODO: Support all the "Properties" too
## TODO: Figure out why Notepad doesn't support SetValue
## TODO: Figure out where the menus support went
ForEach($pattern in $patterns){
   $pattern | Add-Accelerator
   $PatternFullName = $pattern.FullName
   $PatternName = $Pattern.Name -Replace "Pattern","."
   $newline = "`n`t`t"
   
   New-Item "Function:Get-UIAPattern$($PatternName.TrimEnd('.'))" -Value "
   param(
      [Parameter(ValueFromPipeline=`$true)][Alias('Element','AutomationElement')][AutomationElement]`$InputObject
   )
   process { 
      trap { Write-Warning `"`$(`$_)`"; continue }
      Write-Output `$InputObject.GetCurrentPattern([$PatternFullName]::Pattern).Current
   }"
   
   $pattern.GetMethods() | 
   Where { $_.DeclaringType -eq $_.ReflectedType -and !$_.IsSpecialName } | 
   ForEach {
      $FunctionName = "Function:Invoke-$PatternName$($_.Name)"
      $Position = 1
      
      if (test-path $FunctionName) { remove-item $FunctionName }
      $Parameters = @("$newline[Parameter(ValueFromPipeline=`$true)]"+
                      "$newline[Alias('Parent','Element','Root','AutomationElement')]"+
                      "$newline[AutomationElement]`$InputObject"
                      ) + 
                    @(
                      "[Parameter()]$newline[Switch]`$Passthru"
                     ) + 
                    @($_.GetParameters() | % { "[Parameter(Position=$($Position; $Position++))]$newline[$($_.ParameterType.FullName)]`$$($_.Name)" })
      $Parameters = $Parameters -Join "$newline,$newline"
      $ParameterValues = '$' + (@($_.GetParameters() | Select-Object -Expand Name ) -Join ', $')

      $definition = @"
   param(
      $Parameters
   )
   process { 
      ## trap { Write-Warning "`$(`$_)"; break }
      `$pattern = `$InputObject.GetCurrentPattern([$PatternFullName]::Pattern)
      if(`$pattern) {
         `$Pattern.$($_.Name)($(if($ParameterValues.Length -gt 1){ $ParameterValues }))
      }
      if(`$passthru) {
         `$InputObject
      }
   }
"@
      
      trap {
         Write-Warning $_
         Write-Host $definition -fore cyan
      }
      New-Item $FunctionName -value $definition
   }
   
   $pattern.GetProperties() | 
   Where { $_.DeclaringType -eq $_.ReflectedType -and $_.Name -notmatch "Cached|Current"} |
   ForEach {
      $FunctionName = "Function:Get-$PatternName$($_.Name)".Trim('.')
      if (test-path $FunctionName) { remove-item $FunctionName }
      New-Item $FunctionName -value "
      param(
         [Parameter(ValueFromPipeline=`$true)]
         [AutomationElement]`$AutomationElement
      )      
      process { 
         trap { Write-Warning `"$PatternFullName `$_`"; continue }
         `$pattern = `$AutomationElement.GetCurrentPattern([$PatternFullName]::Pattern)
         if(`$pattern) {
            `$pattern.'$($_.Name)'
         }
      }"
   }
   ## So far this seems to be restricted to Text (DocumentRange) elements
   $pattern.GetFields() |
   Where { $_.DeclaringType -eq $_.ReflectedType -and $_.Name -like "*Attribute"} |
   ForEach {
      $FunctionName = "Function:Get-UIAAttribute$PatternName$($_.Name)"
      if (test-path $FunctionName) { remove-item $FunctionName }
      New-Item $FunctionName -value "
      param(
         [Parameter(ValueFromPipeline=`$true)]
         [AutomationElement]`$AutomationElement
      )
      process { 
         trap { Write-Warning `"$PatternFullName `$_`"; continue }
         `$AutomationElement.GetAttributeValue([$PatternFullName]::$($_.Name))
      }"
   }
   
   $pattern.GetFields() |
   Where { $_.DeclaringType -eq $_.ReflectedType -and $_.Name -like "*Event"} |
   ForEach {
      $Name = $_.Name -replace 'Event$','Handler'
      $FunctionName = "Function:Add-$PatternName$Name"
      if (test-path $FunctionName) { remove-item $FunctionName }
      New-Item $FunctionName -value "
      param(
         [Parameter(ValueFromPipeline=`$true)]
         [AutomationElement]`$AutomationElement
      ,
         [System.Windows.Automation.TreeScope]`$TreeScope = 'Element'
      ,
         [ScriptBlock]`$EventHandler
      )
      process { 
         trap { Write-Warning `"$PatternFullName `$_`"; continue }
         [Automation]::AddAutomationEventHandler( [$PatternFullName]::$Name, `$AutomationElement, `$TreeScope, `$EventHandler )
      }"
   }
}

$FalseCondition = [Condition]::FalseCondition
$TrueCondition  = [Condition]::TrueCondition

Add-Type -AssemblyName System.Windows.Forms
Add-Accelerator SendKeys           System.Windows.Forms.SendKeys       -EA SilentlyContinue

$AutomationProperties = [system.windows.automation.automationelement+automationelementinformation].GetProperties()

Set-Alias Invoke-UIAElement Invoke-Invoke.Invoke

function formatter  { END {
   $input | Format-Table @{l="Text";e={$_.Text.SubString(0,25)}}, ClassName, FrameworkId -Auto
}}

function Set-UIAText {
[CmdletBinding()]
param(
   [Parameter(Position=0)]
   [string]$Text
,
   [Parameter(ValueFromPipeline=$true)]
   [Alias("Parent","Element","Root")]
   [AutomationElement]$InputObject
,
   [Parameter()]
   [Switch]$Passthru   
)
   process {
      if(!$InputObject.Current.IsEnabled)
      {
         Write-Warning "The Control is not enabled!"
      }
      if(!$InputObject.Current.IsKeyboardFocusable)
      {
         Write-Warning "The Control is not focusable!"
      }
      
      $valuePattern = $null
      if($InputObject.TryGetCurrentPattern([ValuePattern]::Pattern,[ref]$valuePattern)) {
         Write-Verbose "Set via ValuePattern!"
         $valuePattern.SetValue( $Text )
      } 
      elseif($InputObject.Current.IsKeyboardFocusable) 
      {
         $InputObject.SetFocus();
         [SendKeys]::SendWait("^{HOME}");
         [SendKeys]::SendWait("^+{END}");
         [SendKeys]::SendWait("{DEL}");
         [SendKeys]::SendWait( $Text )
      }
      if($passthru) {
         $InputObject
      }      
   }
}

function Set-UIAFocus {
[CmdletBinding()]
param(
   [Parameter(ValueFromPipeline=$true)]
   [Alias("Parent","Element","Root")]
   [AutomationElement]$InputObject
,
   [Parameter()]
   [Switch]$Passthru   
)
   process {
      $InputObject.SetFocus()
      if($passthru) {
         $InputObject
      }        
   }
}

function Get-UIAClickablePoint {
[CmdletBinding()]
param(
   [Parameter(ValueFromPipeline=$true)]
   [Alias("Parent","Element","Root")]
   [AutomationElement]$InputObject
)
   process {
      $InputObject.GetClickablePoint()
   }
}

function Send-UIAKeys {
[CmdletBinding()]
param(
   [Parameter(Position=0)]
   [string]$Keys
,
   [Parameter(ValueFromPipeline=$true)]
   [Alias("Parent","Element","Root")]
   [AutomationElement]$InputObject
,
   [Parameter()]
   [Switch]$Passthru
,
   [Parameter()]
   [Switch]$Async
)
   process {
      if(!$InputObject.Current.IsEnabled)
      {
         Write-Warning "The Control is not enabled!"
      }
      if(!$InputObject.Current.IsKeyboardFocusable)
      {
         Write-Warning "The Control is not focusable!"
      }
         
      $InputObject.SetFocus();
      
      if($Async) {
         [SendKeys]::Send( $Keys )
      } else {
         [SendKeys]::SendWait( $Keys )
      }
      
      if($passthru) {
         $InputObject
      }      
   }
}

function Select-UIElement {
[CmdletBinding(DefaultParameterSetName="FromParent")]
PARAM (
   [Parameter(ParameterSetName="FromWindowHandle", Position="0", Mandatory=$true)] 
   [Alias("MainWindowHandle","hWnd","Handle")]
   [IntPtr[]]$WindowHandle=[IntPtr]::Zero
,
   [Parameter(ParameterSetName="FromPoint", Position="0", Mandatory=$true)]
   [System.Windows.Point[]]$Point
,
   [Parameter(ParameterSetName="FromParent", ValueFromPipeline=$true, Position=100)]
   [System.Windows.Automation.AutomationElement]$Parent = [UIAutomationHelper]::RootElement
,
   [Parameter(ParameterSetName="FromParent", Position="0")]
   [Alias("WindowName")]
   [String[]]$Name
,
   [Parameter(ParameterSetName="FromParent", Position="1")]
   [System.Windows.Automation.ControlType]
   [StaticField(([System.Windows.Automation.ControlType]))]$ControlType
,
   ## Removed "Id" alias to allow get-process | Select-Window pipeline to find just MainWindowHandle
   [Parameter(ParameterSetName="FromParent", ValueFromPipelineByPropertyName=$true )]
   [Alias("Id")]
   [Int[]]$PID
,
   [Parameter(ParameterSetName="FromParent")]
   [String[]]$ProcessName
,
   [Parameter(ParameterSetName="FromParent")]
   [String[]]$ClassName
,
   [switch]$Recurse

)
process {

   Write-Debug "Parameters Found"
   Write-Debug ($PSBoundParameters | Format-Table | Out-String)

   $search = "Children"
   if($Recurse) { $search = "Descendants" }
   
   $condition = [System.Windows.Automation.Condition]::TrueCondition
   
   Write-Verbose $PSCmdlet.ParameterSetName
   switch -regex ($PSCmdlet.ParameterSetName) {
      "FromWindowHandle" {
         $Element = $(
            foreach($hWnd in $WindowHandle) {
               [System.Windows.Automation.AutomationElement]::FromHandle( $hWnd )
            }
         )
         continue
      }
      "FromPoint" {
         $Element = $(
            foreach($pt in $Point) {
               [System.Windows.Automation.AutomationElement]::FromPoint( $pt )
            }
         )
         continue
      }
      "FromParent" {
         ## [System.Windows.Automation.Condition[]]$conditions = [System.Windows.Automation.Condition]::TrueCondition
         [ScriptBlock[]]$filters = @()
         if($PID) {
            [System.Windows.Automation.Condition[]]$current += $(
               foreach($p in $PID) {
                  new-object System.Windows.Automation.PropertyCondition ([System.Windows.Automation.AutomationElement]::ProcessIdProperty), $p #.id
               }
            )
            if($current.Length -gt 1) {
               [System.Windows.Automation.Condition[]]$conditions += New-Object System.Windows.Automation.OrCondition $current
            } elseif($current.Length -eq 1) {
               [System.Windows.Automation.Condition[]]$conditions += $current[0]
            }
         }
         if($ProcessName) {
            if($ProcessName -match "\?|\*|\[") {
               [ScriptBlock[]]$filters += { $(foreach($p in $ProcessName){ (Get-Process -id $_.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::ProcessIdProperty)).ProcessName -like $p }) -contains $true } 
            } else {
               [System.Windows.Automation.Condition[]]$current += $(
                  foreach($p in Get-Process -Name $ProcessName) {
                     new-object System.Windows.Automation.PropertyCondition ([System.Windows.Automation.AutomationElement]::ProcessIdProperty), $p.id
                  }
               )
               if($current.Length -gt 1) {
                  [System.Windows.Automation.Condition[]]$conditions += New-Object System.Windows.Automation.OrCondition $current
               } elseif($current.Length -eq 1) {
                  [System.Windows.Automation.Condition[]]$conditions += $current[0]
               }               
            }
         }
         if($Name) {
            if($Name -match "\?|\*|\[") {
               [ScriptBlock[]]$filters += { $(foreach($n in $Name){ $_.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::NameProperty) -like $n }) -contains $true } 
            } else {
               [System.Windows.Automation.Condition[]]$current += $(
                  foreach($n in $Name){
                     new-object System.Windows.Automation.PropertyCondition ([System.Windows.Automation.AutomationElement]::NameProperty), $n, "IgnoreCase"
                  }
               )
               if($current.Length -gt 1) {
                  [System.Windows.Automation.Condition[]]$conditions += New-Object System.Windows.Automation.OrCondition $current
               } elseif($current.Length -eq 1) {
                  [System.Windows.Automation.Condition[]]$conditions += $current[0]
               }   
            }
         }
         if($ClassName) {
            if($ClassName -match "\?|\*|\[") {
               [ScriptBlock[]]$filters += { $(foreach($c in $ClassName){ $_.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::ClassNameProperty) -like $c }) -contains $true } 
            } else {
               [System.Windows.Automation.Condition[]]$current += $(
                  foreach($c in $ClassName){
                     new-object System.Windows.Automation.PropertyCondition ([System.Windows.Automation.AutomationElement]::ClassNameProperty), $c, "IgnoreCase"
                  }
               )
               if($current.Length -gt 1) {
                  [System.Windows.Automation.Condition[]]$conditions += New-Object System.Windows.Automation.OrCondition $current
               } elseif($current.Length -eq 1) {
                  [System.Windows.Automation.Condition[]]$conditions += $current[0]
               }                  
            }
         }
         if($ControlType) {
            if($ControlType -match "\?|\*|\[") {
               [ScriptBlock[]]$filters += { $(foreach($c in $ControlType){ $_.GetCurrentPropertyValue([System.Windows.Automation.AutomationElement]::ControlTypeProperty) -like $c }) -contains $true } 
            } else {
               [System.Windows.Automation.Condition[]]$current += $(
                  foreach($c in $ControlType){
                     new-object System.Windows.Automation.PropertyCondition ([System.Windows.Automation.AutomationElement]::ControlTypeProperty), $c
                  }
               )
               if($current.Length -gt 1) {
                  [System.Windows.Automation.Condition[]]$conditions += New-Object System.Windows.Automation.OrCondition $current
               } elseif($current.Length -eq 1) {
                  [System.Windows.Automation.Condition[]]$conditions += $current[0]
               }                  
            }
         }
         
         if($conditions.Length -gt 1) {
            [System.Windows.Automation.Condition]$condition = New-Object System.Windows.Automation.AndCondition $conditions
         } elseif($conditions) {
            [System.Windows.Automation.Condition]$condition = $conditions[0]
         } else {
            Write-Host "Oh no! It's the TRUE condition." -fore red
            [System.Windows.Automation.Condition]$condition = [System.Windows.Automation.Condition]::TrueCondition
         }
         
         if($filters.Count -gt 0) {
            Write-Host "There are Filters too though ... " -fore red
            $Element = $Parent.FindAll( $search, $condition ) | Where-Object { $item = $_;  foreach($f in $filters) { $item = $item | Where $f }; $item }
         } else {
            $Element = $Parent.FindAll( $search, $condition )
         }
      }  
   }
   
   Write-Verbose "Element: $(@($Element).Count)"
   if($Element) {
      foreach($el in $Element) {
         $e = New-Object PSObject $el
         foreach($prop in $e.GetSupportedProperties() | Sort ProgrammaticName)
         {
            ## TODO: make sure all these show up: [System.Windows.Automation.AutomationElement] | gm -sta -type Property
            $propName = [System.Windows.Automation.Automation]::PropertyName($prop)
            Add-Member -InputObject $e -Type ScriptProperty -Name $propName -Value ([ScriptBlock]::Create( "`$this.GetCurrentPropertyValue( [System.Windows.Automation.AutomationProperty]::LookupById( $($prop.Id) ))" )) -EA 0
         }
         foreach($patt in $e.GetSupportedPatterns()| Sort ProgrammaticName)
         {
            Add-Member -InputObject $e -Type ScriptProperty -Name $patt.ProgrammaticName.Replace("PatternIdentifiers.Pattern","") -Value ([ScriptBlock]::Create( "`$this.GetCurrentPattern( [System.Windows.Automation.AutomationPattern]::LookupById( '$($patt.Id)' ) )" )) -EA 0
         }
         Write-Output $e
      }
   }
}

}



#   [Cmdlet(VerbsCommon.Add, "UIAHandler")]
#   public class AddUIAHandlerCommand : PSCmdlet
#   {
#      private AutomationElement _parent = AutomationElement.RootElement;
#      private AutomationEvent _event = WindowPattern.WindowOpenedEvent;
#      private TreeScope _scope = TreeScope.Children;
#
#      [Parameter(ValueFromPipeline = true)]
#      [Alias("Parent", "Element", "Root")]
#      public AutomationElement InputObject { set { _parent = value; } get { return _parent; } }
#
#      [Parameter()]
#      public AutomationEvent Event { set { _event = value; } get { return _event; } }
#
#      [Parameter()]
#      public AutomationEventHandler ScriptBlock { set; get; }
#
#      [Parameter()]
#      public SwitchParameter Passthru { set; get; }
#
#      [Parameter()]
#      public TreeScope Scope { set { _scope = value; } get { return _scope; } }
#
#      protected override void ProcessRecord()
#      {
#         Automation.AddAutomationEventHandler(Event, InputObject, Scope, ScriptBlock);
#
#         if (Passthru.ToBool())
#         {
#            WriteObject(InputObject);
#         }
#
#         base.ProcessRecord();
#      }
#   }


Export-ModuleMember -cmdlet * -Function * -Alias *
# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1J/dovQ2Sib/5ECSBjkJCtAP
# TKmgggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
# AQUFADCBlTELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0
# IExha2UgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYD
# VQQLExhodHRwOi8vd3d3LnVzZXJ0cnVzdC5jb20xHTAbBgNVBAMTFFVUTi1VU0VS
# Rmlyc3QtT2JqZWN0MB4XDTEwMDUxNDAwMDAwMFoXDTExMDUxNDIzNTk1OVowgZUx
# CzAJBgNVBAYTAlVTMQ4wDAYDVQQRDAUwNjg1MDEUMBIGA1UECAwLQ29ubmVjdGlj
# dXQxEDAOBgNVBAcMB05vcndhbGsxFjAUBgNVBAkMDTQ1IEdsb3ZlciBBdmUxGjAY
# BgNVBAoMEVhlcm94IENvcnBvcmF0aW9uMRowGAYDVQQDDBFYZXJveCBDb3Jwb3Jh
# dGlvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMfUdxwiuWDb8zId
# KuMg/jw0HndEcIsP5Mebw56t3+Rb5g4QGMBoa8a/N8EKbj3BnBQDJiY5Z2DGjf1P
# n27g2shrDaNT1MygjYfLDntYzNKMJk4EjbBOlR5QBXPM0ODJDROg53yHcvVaXSMl
# 498SBhXVSzPmgprBJ8FDL00o1IIAAhYUN3vNCKPBXsPETsKtnezfzBg7lOjzmljC
# mEOoBGT1g2NrYTq3XqNo8UbbDR8KYq5G101Vl0jZEnLGdQFyh8EWpeEeksv7V+YD
# /i/iXMSG8HiHY7vl+x8mtBCf0MYxd8u1IWif0kGgkaJeTCVwh1isMrjiUnpWX2NX
# +3PeTmsCAwEAAaOCAW8wggFrMB8GA1UdIwQYMBaAFNrtZHQUnBQ8q92Zqb1bKE2L
# PMnYMB0GA1UdDgQWBBTK0OAaUIi5wvnE8JonXlTXKWENvTAOBgNVHQ8BAf8EBAMC
# B4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzARBglghkgBhvhC
# AQEEBAMCBBAwRgYDVR0gBD8wPTA7BgwrBgEEAbIxAQIBAwIwKzApBggrBgEFBQcC
# ARYdaHR0cHM6Ly9zZWN1cmUuY29tb2RvLm5ldC9DUFMwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC51c2VydHJ1c3QuY29tL1VUTi1VU0VSRmlyc3QtT2JqZWN0
# LmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNv
# bW9kb2NhLmNvbTAhBgNVHREEGjAYgRZKb2VsLkJlbm5ldHRAWGVyb3guY29tMA0G
# CSqGSIb3DQEBBQUAA4IBAQAEss8yuj+rZvx2UFAgkz/DueB8gwqUTzFbw2prxqee
# zdCEbnrsGQMNdPMJ6v9g36MRdvAOXqAYnf1RdjNp5L4NlUvEZkcvQUTF90Gh7OA4
# rC4+BjH8BA++qTfg8fgNx0T+MnQuWrMcoLR5ttJaWOGpcppcptdWwMNJ0X6R2WY7
# bBPwa/CdV0CIGRRjtASbGQEadlWoc1wOfR+d3rENDg5FPTAIdeRVIeA6a1ZYDCYb
# 32UxoNGArb70TCpV/mTWeJhZmrPFoJvT+Lx8ttp1bH2/nq6BDAIvu0VGgKGxN4bA
# T3WE6MuMS2fTc1F8PCGO3DAeA9Onks3Ufuy16RhHqeNcMYICTDCCAkgCAQEwgaow
# gZUxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2FsdCBMYWtl
# IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8GA1UECxMY
# aHR0cDovL3d3dy51c2VydHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNFUkZpcnN0
# LU9iamVjdAIQKQm90jYWUDdv7EgFkuELajAJBgUrDgMCGgUAoHgwGAYKKwYBBAGC
# NwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU4y8DgFgU
# E4gFrdVXpPcBOvsvx+QwDQYJKoZIhvcNAQEBBQAEggEADdDsHJdQxMh9saVCbqer
# SUk3ygs0LAiYF0IozBiHD1tY23CZokYGWAOCSfzF5gOJb9pa2p3oU8aH9PJWBSn7
# HQ1x5RTPqccDUQA03ucgZAN0WQ/V27Zoahox1h8Q597zqp76y4T9bvBjv1lJju9P
# 0tolEvS0uciAQhPgCvxbvRBdWmOKOK5TPSp6hEk3FsPPlgS9xp7twVNI4Kn619Ku
# cKzoZQoTeFwefKuGMSWMVwKugw2ZJKRkTsoPSl4hDjZ2d5cZM+1bbaGOqxmSBeVr
# wD3nfxZhZOGm54jbqu8WvObLB4znvGo1PBVi/vTb13ncdVFHBu10IQeW+STxLfpb
# LQ==
# SIG # End signature block

