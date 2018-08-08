## This is the first version of a Growl module (just dot-source to use in PowerShell 1.0)
## Initially it only supports a very simple notice, and I haven't gotten callbacks working yet
## Coming soon: 
## * Send notices to other PCs directly
## * Wrap the registration of new messages
## * Figure out the stupid 

## Change these to whatever you like, at least the first one, since it should point at a real ico file
$defaultIcon = "$PSScriptRoot\PowerGrowl.ico"
$appName = "PowerGrowler"

[Reflection.Assembly]::LoadFrom("$(Split-Path (gp HKCU:\Software\Growl).'(default)')\Growl.Connector.dll") | Out-Null

if(!(Test-Path Variable:Script:PowerGrowler)) {
   $script:GrowlApp  = New-Object "Growl.Connector.Application" $appName
   $script:PowerGrowler = New-Object "Growl.Connector.GrowlConnector"
   $script:PowerGrowler.EncryptionAlgorithm = [Growl.Connector.Cryptography+SymmetricAlgorithmType]::AES

   [Growl.Connector.NotificationType[]]$global:PowerGrowlerNotices = @("Default")
   ## You should change this
   $global:PowerGrowlerNotices[0].Icon = $defaultIcon
}

## I was going to store these ON the PowerGrowler object, but ...
## I wanted to make the notices editable, without making it editable
## So instead, I add them to it only after you register them....
# Add-Member -InputObject $script:PowerGrowler -MemberType NoteProperty -Name Notices -Value $PowerGrowlerNotices

## Should only (have to) do this once.
$script:PowerGrowler.Register($script:GrowlApp, $global:PowerGrowlerNotices )


## This is test code, it doesn't work -- as far as I can tell, the notification never gets called ...
$script:PowerGrowler.Add_NotificationCallback( { 
   Write-Host "The object $this" -fore Cyan
   Write-Host $("Response Type: {0}\r\nNotification ID: {1}\r\nCallback Data: {2}\r\nCallback Data Type: {3}\r\n" -f $_.Result, $_.NotificationID, $_.Data, $_.Type) -fore Yellow
} )

function Send-Growl {
#.Synopsis
#  Send a growl notice
#.Description
#  Send a growl notice with the scpecified values
#.Parameter Caption
#  The short caption to display
#.Parameter Message
#  The message to send (most displays will resize to accomodate)
#.Parameter NoticeType
#  The type of notice to send. This MUST be the name of one of the registered types, and senders should bear in mind that each registered type has user-specified settings, so you should not abuse the types, but create your own for messages that will recur.
#  For example, the user settings allow certain messages to be disabled, set to a different "Display", or to have their Duration and Stickyness changed, as well as have them be Forwarded to another device, have Sounds play, and set different priorities.
#.Parameter Icon
#  Overrides the default icon of the message (accepts .ico, .png, .bmp, .jpg, .gif etc)
#.Parameter Priority
#  Overrides the default priority of the message (use sparingly)
#.Example
#  Send-Growl "Greetings" "Hello World!"
#
#  The Hello World of Growl.
#.Example
#  Send-Growl "You've got Mail!" "Message for you sir!" -icon ~\Icons\mail.png
#
#  Displays a message with a couple of movie quotes and a mail icon.
#
PARAM (
   [Parameter(Mandatory=$true, Position=0)]
   [string]$Caption=$(Read-Host "A SHORT caption")
,
   [Parameter(Mandatory=$true, Position=1)]
   [string]$Message=$(Read-Host "The detailed message")
#,  [string]$CallbackData
#,  [string]$CallbackType
,
   [Parameter(Mandatory=$false)][Alias("Type")]   
   [string]$NoticeType=$global:PowerGrowlerNotices[0].Name
,
   [string]$Icon
,
   [Growl.Connector.Priority]$Priority = "Normal" 
)

   $notice = New-Object Growl.Connector.Notification $appName, $NoticeType, (Get-Date).Ticks.ToString(), $caption, $Message
   
   if($Icon) { $notice.Icon = Convert-Path (Resolve-Path $Icon) }
   if($Priority) { $notice.Priority = $Priority }
   
   if($DebugPreference -gt "SilentlyContinue") { Write-Output $notice }
   if( $CallbackData -and $CallbackType ) {
      $context = new-object Growl.Connector.CallbackContext
      $context.Data = $CallbackData
      $context.Type = $CallbackType
      $script:PowerGrowler.Notify($notice, $context)
   } else {
      $script:PowerGrowler.Notify($notice)
   }
}

Export-ModuleMember -Function Send-Growl

