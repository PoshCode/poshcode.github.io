<#
	Powershell Lync Bot
	This will respond to the commands below in the switch statement.

	Just a simple script to see how it could be done, took a lot of digging
	as it seems no-one has done this before?

	***Powershell window needs to remain open for events to fire***

	Author: Michael Diarmid
	Email: michael.diarmid@atos.net

#>

# Clear all previous subscribed events
Get-EventSubscriber | Unregister-Event

#Import Lync Model
$ModelPath = "C:\Program Files (x86)\Microsoft Lync\SDK\Assemblies\Desktop\Microsoft.Lync.Model.DLL"

If (Test-Path $ModelPath)
{
	Import-Module $ModelPath
}
Else
{
	Write-Host 'Please Import the "Microsoft.Lync.Model.DLL" Before using Command'
	break
}

# lync client
$client = [Microsoft.Lync.Model.LyncClient]::GetClient()

# Job that is called on new message recieved
$global:action = {
	# get the conversation that caused the event
	$Conversation = $Event.Sender.Conversation
	
	# Create a new msg collection for the response
	$msg = New-Object "System.Collections.Generic.Dictionary[Microsoft.Lync.Model.Conversation.InstantMessageContentType,String]"
	
	# Modality Type
	$Modality = $Conversation.Modalities[1]
	
	# The message recieved
	[string]$msgStr = $Event.SourceArgs.Text
	$msgStr = $msgStr.ToString().ToLower().Trim()
	
	# switch commands / messages - add what you like here
	switch ($msgStr)
	{
		"hey" {
			$msg.Add(1, '<b>hello</b>')
			
		}
		"hi" {
			$msg.Add(1, '<i>Hello</i>')
			
		}
		"hello" {
			$msg.Add(1, '<u>hey</u>')
			
		}
		"moo" {
			$msg.Add(0, 'Are you a cow?')
			
		}
		"help" {
			$msg.Add(0, 'Mr bot at your service!')
			$msg.Add(1, '<b>Available commands:</b>')
			$msg.Add(1, 'hi, hey, hello')
			$msg.Add(1, 'moo')
			$msg.Add(1, 'time')						
		}
		"time" {
			$now = Get-Date
			$msg.Add(0, '' + $now)
		}
		default
		{
				# do nothing 
				$sendMe = 0
		}
	}
	
	if ($sendMe -eq 1)
	{		
		# Send the message
		$null = $Modality.BeginSendMessage($msg, $null, $msg)
	}
}

# Register events for current open conversation participants
foreach ($con in $client.ConversationManager.Conversations)
{
	# For each participant in the conversation
	$moo = $con.Participants | Where { !$_.IsSelf }

	foreach ($mo in $moo)
	{
		$mo.Contact.uri
		if (!(Get-EventSubscriber $mo.Contact.uri))
		{
			Register-ObjectEvent -InputObject $mo.Modalities[1] -EventName "InstantMessageReceived" -SourceIdentifier $mo.Contact.uri -action $global:action
		}
	}
}

# Add event to pickup new conversations and register events for new participants
$conversationMgr = $client.ConversationManager
Register-ObjectEvent -InputObject $conversationMgr `
					 -EventName "ConversationAdded" `
					 -SourceIdentifier "NewIncomingConversation" `
					 -action {
	$client = [Microsoft.Lync.Model.LyncClient]::GetClient()
	foreach ($con in $client.ConversationManager.Conversations)
	{
		# For each participant in the conversation
		$moo = $con.Participants | Where { !$_.IsSelf }
		foreach ($mo in $moo)
		{
			#$mo.Contact.uri
			if (!(Get-EventSubscriber $mo.Contact.uri))
			{
				Register-ObjectEvent -InputObject $mo.Modalities[1] -EventName "InstantMessageReceived" -SourceIdentifier $mo.Contact.uri -action $global:action
			}
		}
	}
	
}


# random junk for testing

#set conversation title
#$con.BeginSetProperty([Microsoft.Lync.Model.Conversation.ConversationProperty]::Subject, "A title woo", $null, $null)
