﻿#requires -Version 3

#region Info

<#
		#################################################
		# modified by     : Joerg Hochwald
		# last modified   : 2016-07-01
		#################################################

		Support: https://github.com/jhochwald/NETX/issues
#>

#endregion Info

#region License

<#
		Copyright (c) 2012-2016, NET-Experts <http:/www.net-experts.net>.
		All rights reserved.

		Redistribution and use in source and binary forms, with or without
		modification, are permitted provided that the following conditions are met:

		1. Redistributions of source code must retain the above copyright notice,
		this list of conditions and the following disclaimer.

		2. Redistributions in binary form must reproduce the above copyright notice,
		this list of conditions and the following disclaimer in the documentation
		and/or other materials provided with the distribution.

		3. Neither the name of the copyright holder nor the names of its
		contributors may be used to endorse or promote products derived from
		this software without specific prior written permission.

		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
		AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
		IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
		ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
		LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
		CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
		SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
		INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
		CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
		ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
		THE POSSIBILITY OF SUCH DAMAGE.

		By using the Software, you agree to the License, Terms and Conditions above!
#>

#endregion License

function global:Send-SlackChat {
	<#
			.SYNOPSIS
			Sends a chat message to a Slack organization

			.DESCRIPTION
			The Post-ToSlack cmdlet is used to send a chat message to a Slack
			channel, group, or person.

			Slack requires a token to authenticate to an organization within Slack.

			.PARAMETER Channel
			Slack Channel to post to

			.PARAMETER Message
			Chat message to post

			.PARAMETER token
			Slack API token

			.PARAMETER BotName
			Optional name for the bot

			.EXAMPLE
			PS C:\> Send-SlackChat -channel '#general' -message 'Hello everyone!' -botname 'The Borg' -token '1234567890'

			Description
			-----------
			This will send a message to the "#General" channel using a specific
			token 1234567890, and the bot's name will be "The Borg".

			.EXAMPLE
			PS C:\> Send-SlackChat -channel '#general' -message 'Hello everyone!' -token '1234567890'

			Description
			-----------
			This will send a message to the "#General" channel using a specific t
			oken 1234567890, and the bot's name will be default ("Build Bot").

			.NOTES
			Based on an idea of @ChrisWahl
			Please note the Name change and the removal of some functions

			.LINK
			Info: https://api.slack.com/tokens

			.LINK
			API: https://api.slack.com/web

			.LINK
			Info: https://api.slack.com/bot-users

			.LINK
			NET-Experts http://www.net-experts.net

			.LINK
			Support https://github.com/jhochwald/NETX/issues
	#>

	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true,
				Position = 0,
		HelpMessage = 'Slack Channel to post to')]
		[ValidateNotNullOrEmpty()]
		[System.String]$Channel,
		[Parameter(Mandatory = $true,
				Position = 1,
		HelpMessage = 'Chat message to post')]
		[ValidateNotNullOrEmpty()]
		[System.String]$Message,
		[Parameter(Position = 2,
		HelpMessage = 'Slack API token')]
		[ValidateNotNullOrEmpty()]
		[System.String]$token,
		[Parameter(Position = 3,
		HelpMessage = 'Optional name for the bot')]
		[Alias('Name')]
		[System.String]$BotName = 'Build Bot'
	)

	BEGIN {
		# Cleanup all variables...
		Remove-Variable -Name 'uri' -Force -Confirm:$false -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
		Remove-Variable -Name 'body' -Force -Confirm:$false -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
		Remove-Variable -Name 'myBody' -Force -Confirm:$false -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
	}

	PROCESS {
		Set-Variable -Name 'uri' -Value $('https://slack.com/api/chat.postMessage')

		# Build the body as per https://api.slack.com/methods/chat.postMessage
		# We convert this to JSON then...
		Set-Variable -Name 'body' -Value $(@{
				token    = $token
				channel  = $Channel
				text     = $Message
				username = $BotName
				parse    = 'full'
		})

		# Convert the Body Variable to JSON Check if the Server understands Compression,
		# could reduce bandwidth Be careful with the Depth Parameter, bigger values means less performance
		Set-Variable -Name 'myBody' -Value $(ConvertTo-Json -InputObject $body -Depth 2 -Compress:$false)

		# Method to use for the RESTful Call
		Set-Variable -Name 'myMethod' -Value $('POST' -as ([System.String] -as [type]))

		# Use the API via RESTful call
		try {(Invoke-RestMethod -Uri $uri -Method $myMethod -Body $body -UserAgent "Mozilla/5.0 (Windows NT; Windows NT 6.1; en-US) NET-Experts WindowsPowerShell Service $CoreVersion" -ErrorAction:Stop -WarningAction:SilentlyContinue)} catch [System.Exception] {
			<#
					Argh!
					That was an Exception...
			#>

			Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
		} catch {
			# Whoopsie!
			# That should not happen...
			Write-Warning -Message "Could not send notification to your Slack $Channel"
		} finally {
			# Cleanup all variables...
			Remove-Variable -Name 'uri' -Force -Confirm:$false -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
			Remove-Variable -Name 'body' -Force -Confirm:$false -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
			Remove-Variable -Name 'myBody' -Force -Confirm:$false -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
		}
	}
}

