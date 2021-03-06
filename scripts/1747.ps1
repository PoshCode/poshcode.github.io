<#
   Name     : Universal Log4Net Logging Module (Logger.psm1)
   Version  : 0.3
   Author   : Joel Bennett (MVP)
   Site     : http://www.HuddledMasses.org/

   Version History:
   0.3 - Cleanupable release.
         Added Udp, Email,  Xml and RollingXml, as well as a "Chainsaw":http`://logging.apache.org/log4j/docs/chainsaw.html logger based on "Szymon Kobalczyk's configuration":http`://geekswithblogs.net/kobush/archive/2005/07/15/46627.aspx.
         Note: there is a "KNOWN BUG with Log4Net UDP":http`://odalet.wordpress.com/2007/01/13/log4net-ip-parsing-bug-when-used-with-framework-net-20/ which can be patched, but hasn't been released.
         Added a Close-Logger method to clean up the Xml logger 
         NOTE: the Rolling XML Logger produces invalid XML, and the XML logger only produces valid xml after it's been closed...
               I did contribute an "XSLT stylesheet for Log4Net":http`://poshcode.org/1746 which you could use as well
         
   0.2 - Configless release. 
         Now configures with inline XML, and supports switches to create "reasonable" default loggers
         Changed all the functions to Write-*Log so they don't overwrite the cmdlets
         Added -Logger parameter to take the name of the logger to use (it must be created beforehand via Get-Logger)
         Created aliases for Write-* to override the cmdlets -- these are easy for users to remove without breaking the module
         ** NEED to write some docs, but basically, this is stupid simple to use, just:
            Import-Module Logger
            Write-Verbose "This message will be saved in your profile folder in a file named PowerShellLogger.log (by default)"
         To change the defaults for your system, edit the last line in the module!!
   0.1 - Initial release. http`://poshcode.org/1744 (Required config: http`://poshcode.org/1743)

   Uses Log4Net : http`://logging.apache.org/log4net/download.html
   Documentation: http`://logging.apache.org/log4net/release/sdk/
   
   NOTES:
   By default, this overwrites the Write-* cmdlets for Error, Warning, Debug, Verbose, and even Host.
   This means that you may end up logging a lot of stuff you didn't intend to log (ie: verbose output from other scripts)
   
   To avoid this behavior, remove the aliases after importing it
   Import-Module Logger; Remove-Item Alias:Write-*
   Write-Warning "This is your warning"
   Write-Debug   "You should know that..."
   Write-Verbose "Everything would be logged, otherwise"

   ***** NOTE: IT ONLY OVERRIDES THE DEFAULTS FOR SCRIPTS *****
   It currently has no effect on error/verbose/warning that is logged from cmdlets.
   
#>


Add-Type -Path $PSScriptRoot\log4net.dll

function Get-Logger {
param( 
   [Parameter(Mandatory=$false)]
   [string]$LoggerName = "*"
,
   [Parameter(Mandatory=$false)]
   [ValidateSet("DEBUG","INFO","WARN","ERROR","FATAL","VERBOSE","HOST","WARNING")]
   [string]$LogLevel = "DEBUG"
,
   [Parameter(Mandatory=$false)]
   $MessagePattern = "%date %-5level %logger [%property{NDC}] - %message%newline"
,
   [Parameter(Mandatory=$false)]
   [string]$LogFolder = $PSScriptRoot
   
,  [String]$EmailTo
,  [Switch]$Force
,  [Switch]$Console
,  [Switch]$EventLog
,  [Switch]$Trace
,  [Switch]$DebugAppender
,  [Switch]$File
,  [Switch]$RollingFile
,  [Switch]$Xml
,  [Switch]$RollingXml
,  [Switch]$Udp
,  [Switch]$Chainsaw
)
   Remove-Variable Loggers -EA 0
   [log4net.LogManager]::GetCurrentLoggers() | Where-Object { $_.Logger.Name -Like $LoggerName } | Tee-Object -Variable Loggers
   if(!$Loggers -or $Force -and $LoggerName -ne "*") {

      if($LogLevel -eq "VERBOSE") { $LogLevel = "INFO" }
      if($LogLevel -eq "HOST") { $LogLevel = "INFO" }
      if($LogLevel -eq "WARNING") { $LogLevel = "WARN" }

      $AppenderRefs = ''
      if($Email)        { 
         if(!$PSEmailServer) { throw "You need to specify your SMTP mail server by setting the global $PSEmailServer variable" }
         $AppenderRefs += "<appender-ref ref=""SmtpAppender"" />`n"
         $Null,$Domain = $email -split "@",2
      } 
      if($EventLog)     { $AppenderRefs += "<appender-ref ref=""EventLogAppender"" />`n" }
      if($Trace)        { $AppenderRefs += "<appender-ref ref=""TraceAppender"" />`n" }
      if($DebugAppender){ $AppenderRefs += "<appender-ref ref=""DebugAppender"" />`n" }
      if($File)         { $AppenderRefs += "<appender-ref ref=""FileAppender"" />`n" }
      if($RollingFile)  { $AppenderRefs += "<appender-ref ref=""RollingFileAppender"" />`n" }
      if($Udp)          { $AppenderRefs += "<appender-ref ref=""UdpAppender"" />`n" } 
      if($Chainsaw)     { $AppenderRefs += "<appender-ref ref=""UdpLog4JAppender"" />`n" } 
      if($Xml)          { $AppenderRefs += "<appender-ref ref=""XmlAppender"" />`n" } 
      if($RollingXml)   { $AppenderRefs += "<appender-ref ref=""RollingXmlAppender"" />`n" } 
      if($Console -or ($AppenderRefs.Length -eq 0)) { $AppenderRefs += "<appender-ref ref=""ColoredConsoleAppender"" />`n" }

      [log4net.LogManager]::GetLogger($LoggerName) | Tee-Object -Variable Script:Logger
     
      [xml]$config = @"
<log4net>
   <appender name="ColoredConsoleAppender" type="log4net.Appender.ColoredConsoleAppender">
      <mapping>
         <level value="FATAL" />
         <foreColor value="Red, HighIntensity" />
         <backColor value="White, HighIntensity" />
      </mapping>
      <mapping>
         <level value="ERROR" />
         <foreColor value="Red, HighIntensity" />
      </mapping>
      <mapping>
         <level value="DEBUG" />
         <foreColor value="Green, HighIntensity" />
      </mapping>
      <mapping>
         <level value="INFO" />
         <foreColor value="Cyan, HighIntensity" />
      </mapping>
      <mapping>
         <level value="WARN" />
         <foreColor value="Yellow, HighIntensity" />
      </mapping>
      <layout type="log4net.Layout.PatternLayout">
         <conversionPattern value="$MessagePattern" />
      </layout>
   </appender>
   <appender name="EventLogAppender" type="log4net.Appender.EventLogAppender" >
      <applicationName value="$LoggerName" />
      <layout type="log4net.Layout.PatternLayout">
         <conversionPattern value="$MessagePattern" />
      </layout>
   </appender>
   <appender name="TraceAppender" type="log4net.Appender.TraceAppender">
      <layout type="log4net.Layout.PatternLayout">
         <conversionPattern value="$MessagePattern" />
      </layout>
   </appender>
   <appender name="DebugAppender" type="log4net.Appender.DebugAppender">
      <layout type="log4net.Layout.PatternLayout">
         <conversionPattern value="$MessagePattern" />
      </layout>
   </appender>
   <appender name="FileAppender" type="log4net.Appender.FileAppender">
      <file value="$LogFolder\$LoggerName.Log" />
      <appendToFile value="true" />
      <layout type="log4net.Layout.PatternLayout">
         <conversionPattern value="$MessagePattern" />
      </layout>
   </appender>
   <appender name="XmlAppender" type="log4net.Appender.FileAppender">
      <file value="$LogFolder\$LoggerName.xml" />
      <appendToFile value="false" />
      <layout type="log4net.Layout.XmlLayout">
         <Header value="&lt;?xml version='1.0' ?&gt;
&lt;?xml-stylesheet type="text/xsl" href="log4net.xslt"?&gt;
&lt;events version='1.2' xmlns='http://logging.apache.org/log4net/schemas/log4net-events-1.2'&gt;
"/>
         <Footer value="&lt;/events&gt;"/>
         <Prefix value="" />
      </layout>
   </appender>
   <appender name="RollingFileAppender" type="log4net.Appender.RollingFileAppender">
      <file value="$LogFolder\$LoggerName.Log" />
      <appendToFile value="true" />
      <maximumFileSize value="100KB" />
      <maxSizeRollBackups value="2" />
      <layout type="log4net.Layout.PatternLayout">
         <conversionPattern value="$MessagePattern" />
      </layout>
   </appender>
   <appender name="RollingXmlAppender" type="log4net.Appender.RollingFileAppender">
      <file value="$LogFolder\$LoggerName.xml" />
      <appendToFile value="true" />
      <maximumFileSize value="500KB" />
      <maxSizeRollBackups value="2" />
      <layout type="log4net.Layout.XmlLayout">
         <Prefix value="" />
      </layout>
   </appender>
   <appender name="UdpAppender" type="log4net.Appender.UdpAppender">
      <param name="RemoteAddress" value="localhost" />
      <param name="RemotePort" value="8080" />
      <param name="Encoding" value="utf-8" />
      <layout type="log4net.Layout.XmlLayout">
         <param name="Prefix" value="" />
      </layout>
      <param name="threshold" value="DEBUG" />
   </appender>
   <appender name="UdpLog4JAppender" type="log4net.Appender.UdpAppender">
      <param name="RemoteAddress" value="127.0.0.1" />
      <param name="RemotePort" value="8080" />
      <param name="Encoding" value="utf-8" />
      <layout type="log4net.Layout.XmlLayoutSchemaLog4j, log4net" />
      <param name="threshold" value="DEBUG" />
   </appender>
   <appender name="SmtpAppender" type="log4net.Appender.SmtpAppender">
      <to value="$Email" />
      <from value="PoshLogger@$Domain" />
      <subject value="PowerShell Logger Message" />
      <smtpHost value="$PSEmailServer" />
      <bufferSize value="512" />
      <lossy value="true" />
      <evaluator type="log4net.Core.LevelEvaluator">
         <threshold value="WARN"/>
      </evaluator>
      <layout type="log4net.Layout.PatternLayout">
         <conversionPattern value="%newline$MessagePattern%newline%newline" />
      </layout>
   </appender>
   <root>
      <level value="DEBUG" />
   </root>
   <logger name="$LoggerName">
      <level value="$LogLevel" />
      $AppenderRefs
   </logger>
</log4net>
"@
      [log4net.Config.XmlConfigurator]::Configure( $config.log4net )
   }
}

function Set-Logger {
param(
   [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
   [log4net.Core.LogImpl]$Logger
)
   $script:Logger = $Logger
}

function Close-Logger {
param(
   [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
   [log4net.Core.LogImpl]$Logger
)
PROCESS {
   if($Logger) {
      $Logger.Logger.CloseNestedAppenders()
      $Logger.Logger.RemoveAllAppenders()
   } else {
      [log4net.LogManager]::Shutdown()
   }
}
}



function Push-LogContext {
param( 
   [Parameter(Mandatory=$true)]
   [string]$Name
)
   [log4net.NDC]::Push($Name)
}
function Pop-LogContext {
   [log4net.NDC]::Pop()
}

function Write-DebugLog {
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [Alias('Msg')]
    [AllowEmptyString()]
    [System.String]
    ${Message}
,
   [Parameter(Mandatory=$false, Position=99)]
   ${Logger})

begin
{
    try {
        if($PSBoundParameters.ContainsKey("Logger")) {
            if($Logger -is [log4net.Core.LogImpl]) { Set-Logger $Logger } else { $script:Logger = Get-Logger "$Logger" }
            $null = $PSBoundParameters.Remove("Logger")
        }
        
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Write-Debug', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        throw
    }
}

process
{
    try {
        $script:logger.debug($Message) #Write-Debug
        $steppablePipeline.Process($_)
    } catch {
        throw
    }
}

end
{
    try {
        $steppablePipeline.End()
    } catch {
        throw
    }
}
<#

.ForwardHelpTargetName Write-Debug
.ForwardHelpCategory Cmdlet

#>
}
function Write-VerboseLog {

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [Alias('Msg')]
    [AllowEmptyString()]
    [System.String]
    ${Message}
,
   [Parameter(Mandatory=$false, Position=99)]
   ${Logger})

begin
{
    try {
        if($PSBoundParameters.ContainsKey("Logger")) {
            if($Logger -is [log4net.Core.LogImpl]) { Set-Logger $Logger } else { $script:Logger = Get-Logger "$Logger" }
            $null = $PSBoundParameters.Remove("Logger")
        }

        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Write-Verbose', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        throw
    }
}

process
{
    try {
        $script:logger.info($Message)
        $steppablePipeline.Process($_)
    } catch {
        throw
    }
}

end
{
    try {
        $steppablePipeline.End()
    } catch {
        throw
    }
}
<#

.ForwardHelpTargetName Write-Verbose
.ForwardHelpCategory Cmdlet

#>
}
function Write-WarningLog {
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [Alias('Msg')]
    [AllowEmptyString()]
    [System.String]
    ${Message}
,
   [Parameter(Mandatory=$false, Position=99)]
   ${Logger})

begin
{
    try {
        if($PSBoundParameters.ContainsKey("Logger")) {
            if($Logger -is [log4net.Core.LogImpl]) { Set-Logger $Logger } else { $script:Logger = Get-Logger "$Logger" }
            $null = $PSBoundParameters.Remove("Logger")
        }

        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Write-Warning', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        throw
    }
}

process
{
    try {
        $script:logger.warn($Message)  #Write-Warning
        $steppablePipeline.Process($_)
    } catch {
        throw
    }
}

end
{
    try {
        $steppablePipeline.End()
    } catch {
        throw
    }
}
<#

.ForwardHelpTargetName Write-Warning
.ForwardHelpCategory Cmdlet

#>
}
function Write-ErrorLog {
[CmdletBinding(DefaultParameterSetName='NoException')]
param(
    [Parameter(ParameterSetName='WithException', Mandatory=$true)]
    [System.Exception]
    ${Exception},

    [Parameter(ParameterSetName='NoException', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [Parameter(ParameterSetName='WithException')]
    [Alias('Msg')]
    [AllowNull()]
    [AllowEmptyString()]
    [System.String]
    ${Message},

    [Parameter(ParameterSetName='ErrorRecord', Mandatory=$true)]
    [System.Management.Automation.ErrorRecord]
    ${ErrorRecord},

    [Parameter(ParameterSetName='NoException')]
    [Parameter(ParameterSetName='WithException')]
    [System.Management.Automation.ErrorCategory]
    ${Category},

    [Parameter(ParameterSetName='WithException')]
    [Parameter(ParameterSetName='NoException')]
    [System.String]
    ${ErrorId},

    [Parameter(ParameterSetName='NoException')]
    [Parameter(ParameterSetName='WithException')]
    [System.Object]
    ${TargetObject},

    [System.String]
    ${RecommendedAction},

    [Alias('Activity')]
    [System.String]
    ${CategoryActivity},

    [Alias('Reason')]
    [System.String]
    ${CategoryReason},

    [Alias('TargetName')]
    [System.String]
    ${CategoryTargetName},

    [Alias('TargetType')]
    [System.String]
    ${CategoryTargetType}
,
   [Parameter(Mandatory=$false, Position=99)]
   ${Logger})

begin
{
    try {
        if($PSBoundParameters.ContainsKey("Logger")) {
            if($Logger -is [log4net.Core.LogImpl]) { Set-Logger $Logger } else { $script:Logger = Get-Logger "$Logger" }
            $null = $PSBoundParameters.Remove("Logger")
        }

        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Write-Error', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        throw
    }
}

process
{
    try {
        $script:logger.error($Message,$Exception) #Write-Error
        $steppablePipeline.Process($_)
    } catch {
        throw
    }
}

end
{
    try {
        $steppablePipeline.End()
    } catch {
        throw
    }
}
<#

.ForwardHelpTargetName Write-Error
.ForwardHelpCategory Cmdlet

#>
}
function Write-HostLog {
[CmdletBinding()]
param(
    [Parameter(Position=0, ValueFromPipeline=$true, ValueFromRemainingArguments=$true)]
    [System.Object]
    ${Object},

    [Switch]
    ${NoNewline},

    [System.Object]
    ${Separator} = $OFS,

    [System.ConsoleColor]
    ${ForegroundColor},

    [System.ConsoleColor]
    ${BackgroundColor}
,
   [Parameter(Mandatory=$false, Position=99)]
   ${Logger})

begin
{
    try {
        if($PSBoundParameters.ContainsKey("Logger")) {
            if($Logger -is [log4net.Core.LogImpl]) { Set-Logger $Logger } else { $script:Logger = Get-Logger "$Logger" }
            $null = $PSBoundParameters.Remove("Logger")
        }

        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Write-Host', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        throw
    }
}

process
{
    try {
        $script:logger.info(($Object -join $Separator))  #Write-Verbose
        $steppablePipeline.Process($_)
    } catch {
        throw
    }
}

end
{
    try {
        $steppablePipeline.End()
    } catch {
        throw
    }
}
<#

.ForwardHelpTargetName Write-Host
.ForwardHelpCategory Cmdlet

#>
}

Set-Alias Write-Debug Write-DebugLog
Set-Alias Write-Verbose Write-VerboseLog
Set-Alias Write-Warning Write-WarningLog
Set-Alias Write-Error Write-ErrorLog
#Set-Alias Write-Host Write-HostLog

Export-ModuleMember -Function * -Alias *

$script:Logger = Get-Logger "PowerShellLogger" -RollingFile -LogFolder (Split-Path $Profile.CurrentUserAllHosts) 

## THIS IS THE DEFAULT LOGGER. CONFIGURE AS YOU SEE FIT
