#.SYNOPSIS
#  A few functions for working with FriendFeed and Twitter
#.DESCRIPTION
#  Allows you to copy your users from Twitter to imaginary FriendFeed users...
#.EXAMPLE
# ## Get any twitter friends who aren't on friendfeed
# ## Make sure you use FriendFeed's built in "add all your twitter friends" first
# $twits = Get-TwitterFriends `
#         -Nickname jaykul
#         -Exclude $(Get-FriendFeedFriends jaykul | select -expand twitter)
#
# ## YOU MIGHT want to remove people who aren't updating, while you're messing around ...
# $threshold = (Get-Date).AddDays(-14)
# $twits = $twits | Where { $_.protected -or ([DateTime]::ParseExact($_.status.created_at, "ddd MMM dd HH:mm:ss +0000 yyyy", $Null) -gt $threshold) }
#
# ## Add them to friend feed
# foreach($twit in $twits) {
#    New-ImaginaryFriend $twit.name @{twitter=$twit.screen_name} $twit.profile_image_url
# }

function New-ImaginaryFriend {
##.Note
##    DEPENDS on the WatiN module in https://PoshCode.org/1108
##.Synopsis
##    Creates a new "Imaginary Friend" on friendfeed by automating your browser
##.Example
##    New-ImaginaryFriend PoshCode @{Twitter="PoshCode"} https://PoshCode.org/PoshCode.png
##
[CmdletBinding()]
PARAM($name,[hashtable]$services,$avatar)
## BEGIN ...
   if($global:ie -is [WatiN.Core.IE]) {
      New-Watin "http`://friendfeed.com/settings/imaginary"
      while( $ie.Url -ne "http`://friendfeed.com/settings/imaginary" ) {
         Set-WatinUrl "http`://friendfeed.com/settings/imaginary"
         Read-Host "Press Enter after you have logged into FriendFeed"
      }
   }
## TEST/Validate
   Set-WatinUrl http`://friendfeed.com/settings/imaginary
   if($ie.Url -ne "http`://friendfeed.com/settings/imaginary" ) {
      throw "You are not authenticated to FriendFeed. Please log in and try again"
   }

## PROCESS
   Find-Button value "Create imaginary friend" | % { $_.Click() }
   Find-TextField name name | % { $_.TypeText( $name ) }
   (Find-Form action "/a/createimaginary").Buttons | % { $_.click() }

   $null = $ie.url -match "http`://friendfeed.com/([^/]*)/services";
   $ffid = $matches[1]
   # Write-Output $ffid

   foreach($service in $services.GetEnumerator()) {
      Write-Verbose "$($service.Key): $($service.Value)"
      Find-Link service $service.Key | % { $_.Click() }
      $form = Find-Form action "/a/configureservice"
      @($form.TextFields)[0].TypeText( $service.Value )
      @($form.Buttons)[0].click();
   }

   if($avatar) {
      Set-WatinUrl "http`://friendfeed.com/$ffid"
      $avatarFile = Get-WebFile $avatar ([uri]$avatar).segments[-1]
      Write-Verbose "Downloaded? $($avatarFile.FullName)"
      Start-Sleep -milli 500
      Find-Link innertext "Change picture" | %{ $_.Click() }
      Find-FileUpload id pictureupload | % { $_.Set( $avatarFile.FullName ) }
      (Find-Form action "/a/changepicture").Buttons | % { $_.click() }
      Start-Sleep -milli 500
      Remove-Item $avatarFile
   }
}


## DEPENDS on the HttpRest module in https://PoshCode.org/1107
Function Get-FriendFeedFriends {
Param([string]$UserName,[string[]]$Exclude)
   $friendNames = Get-WebPageText "http`://friendfeed.com/api/user/$username/profile" //user/subscription/nickname @{format="xml";include="subscriptions"} |
                  Where {$Exclude -notcontains $_ }

   ForEach($incoming in (Get-WebPageContent "http`://friendfeed.com/api/profiles" //profiles/profile @{ format="xml"; nickname=$($friendNames -join ",") })) {
      $output = Select -Input $incoming Name, NickName |
      Add-Member noteproperty Lists @($incoming.SelectNodes("//list/nickname").InnerText) -Passthru |
      Add-Member noteproperty Rooms @($incoming.SelectNodes("//room/nickname").InnerText) -Passthru
      ForEach($service in $incoming.service) {
         if(!$output."$($service.id)") {
            if($service.username) {
               Add-Member -input $output noteproperty $service.id $service.username
            } else {
               Add-Member -input $output noteproperty $service.id $service.profileUrl
            }
         } else {
            if($service.username) {
               $output."$($service.id)" = @($output."$($service.id)") + $service.username
            } else {
               $output."$($service.id)" = @($output."$($service.id)") + $service.profileUrl
            }
         }
      }
      $output
   }
}

## DEPENDS on the HttpRest module in https://PoshCode.org/1107
function Get-TwitterFriends {
Param($UserName, [string[]]$Exclude)
   $page = 0; $tweeters = @()
   do {
      $tweeters = Get-WebPageContent "http`://twitter.com/statuses/friends.xml" //users/user @{page=(++$page); screen_name=$UserName} |
                  Where {$Exclude -notcontains $_.screen_name }
      Write-Output $tweeters
   } while($tweeters)
}

