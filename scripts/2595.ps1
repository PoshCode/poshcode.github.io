function Get-Scope {
#.Synopsis 
#  Determine the scope of execution (are you in a module? how many scope layers deep are you?)
#.Parameter Invocation
#  In order to correctly determine the scope, this function requires that you pass in the $MyInvocation variable when you call it.
#.Parameter ToHost
#  If you just want to *see* the value in the console to debug something, you can pass this switch (and optionally, set the foreground/background colors)
#.Parameter Foreground
#  The Foreground color of host output
#.Parameter Background
#  The Background color of host output
#.Example
# $scope = Get-Scope $MyInvocation
#
# Description
# -----------
# Call Get-Scope and store the output so you can test if you're in module scope, etc.
#.Example
# Get-Scope $MyInvocation -ToHost Magenta DarkBlue
#
# Description
# -----------
# Call Get-Scope and write the output to host, specifying the foreground and background colors

[CmdletBinding()]
param(
   [Parameter(Position=0,Mandatory=$true)]
   [System.Management.Automation.InvocationInfo]$Invocation
,
   [Parameter(ParameterSetName="Debugging",Mandatory=$true)]
   [Switch]$ToHost
,
   [Parameter(Position=1,ParameterSetName="Debugging")]
   [ConsoleColor]$Foreground = "Cyan"
,
   [Parameter(Position=2,ParameterSetName="Debugging")]
   [ConsoleColor]$Background = "Black"
)
end {
   function Get-ScopeDepth {
      trap { continue }
      $depth = 0
      do {
        Set-Variable scope_test -Scope (++$depth)
      } while($?)
      return $depth - 1
   }
   $depth = Get-ScopeDepth
   
   Remove-Variable scope_test
   New-Variable scope_test

   $PSScope = New-Object PSObject -Property @{ 
      IsModuleScope = [bool]$Invocation.MyCommand.Module
      IsGlobalScope = [bool](Get-Variable scope_test -Scope global -ea 0)
      IsScriptScope = [bool](Get-Variable scope_test -Scope script -ea 0)
      ScopeDepth  = $depth
      PipelinePosition = $Invocation.PipelinePosition
      PipelineLength = $Invocation.PipelineLength
      StackDepth = (Get-PSCallStack).Count - 1
      Invocation = $Invocation
      CallStack = Get-PSCallStack
   }
   
   if($ToHost) {
      &{
         $PSScope, $PSScope.Invocation | Out-String 
      } | Write-Host -Foreground $Foreground -Background $Background
   } else {
      $PSScope
   }
}}

