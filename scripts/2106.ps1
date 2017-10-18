if(-not(get-command New-System.Windows.Window -EA 0)){  Import-Module PowerBoots  }
Add-BootsTemplate $PSScriptRoot\PresentationFrame.xaml

$name = [System.Windows.Navigation.JournalEntry]::NameProperty
[double]$global:zoomLevel = 1
$SlideCount = 0

function Start-Zoom {
PARAM(
   [Parameter(Position=0)]
   $Zoom = 0
,
   [Parameter(ValueFromPipeline=$true)]
   $Root = $($global:Frame)
,
   [Parameter()]
   $Window = $presentationTitle
)
$null =  Invoke-BootsWindow $Window {
   Param($Window,$Root)
   if(!$Root.RenderTransform.Children) {
      $Root.RenderTransform = TransformGroup {
         ScaleTransform -ScaleX $zoomLevel -ScaleY $zoomLevel
         TranslateTransform
      }

      $BootsWindow.Add_MouseDown( {
         if($zoomLevel -ne 1) {
            trap { Write-Host $( $_ | fl * | out-string ) }
            $global:MouseDownPoint = [System.Windows.Input.Mouse]::GetPosition($BootsWindow)
            $this.CaptureMouse()
         }
      } )
      $BootsWindow.Add_MouseUp( { 
         if($zoomLevel -ne 1) {
            trap { Write-Host $( $_ | fl * | out-string ) }
            $this.ReleaseMouseCapture()
         }
      } )
      $BootsWindow.Add_MouseMove( {
         if($zoomLevel -ne 1) {
            trap { Write-Host $( $_ | fl * | out-string ) }
            if($_.LeftButton -eq "Pressed") {
               $newPos = [System.Windows.Input.Mouse]::GetPosition($BootsWindow)

               $this.Content.RenderTransform.Children[1].SetValue( 
                  [System.Windows.Media.TranslateTransform]::XProperty, 
                  $this.Content.RenderTransform.Children[1].Value.OffsetX + ($newPos.X - $MouseDownPoint.X) )

               $this.Content.RenderTransform.Children[1].SetValue( 
                  [System.Windows.Media.TranslateTransform]::YProperty, 
                  $this.Content.RenderTransform.Children[1].Value.OffsetY + ($newPos.Y - $MouseDownPoint.Y) )

               $global:MouseDownPoint = $newPos;
            }
         }
      } )
   }
} $Root
}

function Set-Zoom {
PARAM(
   [Parameter(Position=0)]
   $Zoom = 0
,
   [Parameter()]
   $Root = $global:Frame
,
   [Parameter()]
   $Window = $presentationTitle
)
   if($Zoom -gt 0) {
      $global:zoomLevel *= (1+($Zoom/10))
   } elseif($Zoom -lt 0) {
      $global:zoomLevel /= (1+($Zoom/-10))
   } else {
      $global:zoomLevel = 1.0
   }
   
$null = Invoke-BootsWindow $Window {
   Param($Window,$Root)
   $Root.RenderTransform.Children[0].SetValue( 
      [System.Windows.Media.ScaleTransform]::ScaleXProperty, $zoomLevel )

   $Root.RenderTransform.Children[0].SetValue( 
      [System.Windows.Media.ScaleTransform]::ScaleYProperty, $zoomLevel )

   ## Note that we have to account for rounding errors ;)
   if([Math]::Round($zoomLevel, 10) -eq 1.0 ) {
      $Root.NavigationUIVisibility = "Visible"
      
      $Root.RenderTransform.Children[1].SetValue( 
         [System.Windows.Media.TranslateTransform]::XProperty, 0.0 )

      $Root.RenderTransform.Children[1].SetValue( 
         [System.Windows.Media.TranslateTransform]::YProperty, 0.0 )      
   } else {
      $Root.NavigationUIVisibility = "Hidden"
   }
} $Root
}

function Show-Url {
[CmdletBinding()]
PARAM(
   [Parameter(Position=0, ValueFromPipeline=$true)]
   [Uri]$Content
,
   [Parameter()]
   $Window = $presentationTitle
)
Invoke-BootsWindow $Window {
   $global:Frame.Navigate( $Content )
}
}
New-Alias Navigate Show-Url  # backwards compat

function Add-Slide {
#.Synopsis
#  Add a slide to the presentation
#.Description
#  Add any .net object as a slide to a presentation, wrapping it in a Page to set the title.
[CmdletBinding(DefaultParameterSetName="Script")]
PARAM(
   [Parameter(Position=0,ValueFromPipelineByPropertyName=$true)]
   [Alias("Name")]
   [String]$Title   = "Slide $SlideCount"
,  [Parameter(Position=1, ValueFromPipeline=$true, Mandatory=$true)]
   $Content
,  [Parameter()]
   $Window = $presentationTitle
)
PROCESS {
   $SlideCount++
   Invoke-BootsWindow $Window {
      Param($Frame, $Content, $Title)
      $Frame.Content = Page -Content $Content -Title $Title
   } $global:Frame $Content $Title
}
}

function Add-TextSlide {
#.Synopsis
#  Add a text slide to the presentation
#.Description
#  Add a textual slide to the presentation with a header and several points
[CmdletBinding()]
PARAM(
   [Parameter(Position=0)]
   $Title   = "Slide $SlideCount"
,  [Parameter(Position=1, ValueFromPipeline=$true)]
   [string[]]$Content = @("Several bullet points", "Which are equally important")
,  [Parameter()]
   $Window = $presentationTitle
)
BEGIN   { [string[]]$global:Points = @() }
PROCESS { [string[]]$global:Points += $Content }
END {
   Add-Slide -Title $Title -Window $Window -Content {
      StackPanel -Margin 10 {
         grid {
            TextBlock $Title  -FontSize 85 -FontFamily Impact -Foreground White -Effect { BlurEffect -Radius 15 } -TextAlign Center
            TextBlock $Title  -FontSize 85 -FontFamily Impact -Foreground $global:TitleBrush -TextAlign Center
         }
         write-host "Points: $Points"
         $Points | % { 
            TextBlock $_ -FontSize 64 -FontWeight Bold -Foreground "White" -TextWrapping Wrap -Effect { DropShadowEffect -BlurRadius 15 }
         }
      }
   }.GetNewClosure()
}
}

function Add-TitleSlide {
#.Synopsis
#  Add a text slide to the presentation
#.Description
#  Add a textual slide to the presentation with a header and several points
[CmdletBinding()]
PARAM(
   [Parameter(Position=0)]
   $Title
,   [Parameter()]
   $Window = $presentationTitle
)
BEGIN   { [string[]]$Points = @() }
PROCESS { [string[]]$Points += $Content }
END {
   Add-Slide -Title $Title -Window $Window -Content {
      Grid {
         TextBlock $Title `
            -FontSize 125 -FontFamily Impact -Foreground White `
            -VerticalAlignment Center -TextAlignment Center    `
            -HorizontalAlignment Stretch -TextWrapping Wrap    `
            -Effect { BlurEffect -Radius 20 }
         TextBlock $Title `
            -FontSize 125 -FontFamily Impact -Foreground White `
            -VerticalAlignment Center -TextAlignment Center    `
            -HorizontalAlignment Stretch -TextWrapping Wrap    `
            -Effect { BlurEffect -Radius 20 }
         TextBlock $Title `
            -FontSize 125 -FontFamily Impact -Foreground $global:TitleBrush `
            -VerticalAlignment Center -TextAlignment Center    `
            -HorizontalAlignment Stretch -TextWrapping Wrap    `
            -Effect {DropShadowEffect -Color White -Radius 15}
      }
   }
}
}

function Remove-Slide {
#.Synopsis 
#  Removes the specified slide from the deck (history)
#.Description
#  Takes an index or name, and removes that slide, except that you CANNOT remove the last slide.
PARAM(
   [Parameter(ParameterSetName="ByIndex", Mandatory=$true, Position=0)]
   [int]$index
,  [Parameter(ParameterSetName="ByTitle",  Mandatory=$true, Position=0)]
   [Alias("Name")]
   [string]$Title
,  [Parameter()]
   $Window = $presentationTitle
) 
   $null = Invoke-BootsWindow $Window {
      # Figure out where we are now, because we'll need to come back
      $global:currentSlide = @($global:Frame.BackStack.GetEnumerator()).Count
      # Activate the slide they want to delete ...
      [int]$removable = Set-Slide @PsBoundParameters -passthru
   }
   # Separate Invoke's are required for the window to register what's going on?
   $global:removable = $true
   $null = Invoke-BootsWindow $Window {
      if($global:Frame.CanGoForward) {
         $global:Frame.GoForward()
      } else {
         $global:removable = $false
         Write-Host "Sorry, you can't remove the last slide in the deck." -Fore Red
      }
   }
   if($global:removable) {
      # Separate Invoke's are required for the window to register what's going on?
      Invoke-BootsWindow $Window {
         $null = $global:Frame.RemoveBackEntry()
         Set-Slide $currentSlide
      }
   }
}

function Show-Slide {
#.Synopsis
#  Set the active slide in a deck
#.Description
#  Sets the active slide by index or name (title)
[CmdletBinding(DefaultParameterSetName="ByIndex")]
PARAM(
   [Parameter(ParameterSetName="ByIndex", Mandatory=$true, Position=0)]
   [int]$index
,  [Parameter(ParameterSetName="ByTitle",  Mandatory=$true, Position=0)]
   [Alias("Name")]
   [string]$Title
,  [Parameter()]
   $Window = $presentationTitle
,  [Parameter()]
   [Switch]$Passthru
) 
switch($PSCmdlet.ParameterSetName) {
   "ByIndex" {
      $null = Invoke-BootsWindow $Window {
         # Figure out where we are now...
         [int]$global:current = @($global:Frame.BackStack.GetEnumerator()).Count
         # Then go where we need to
         for(;$current -lt $index -and $global:Frame.CanGoForward ;$global:current++) {
            $global:Frame.GoForward()
         }
         for(;$current -gt $index -and $global:Frame.CanGoBack ;$global:current--) {
            $global:Frame.GoBack()
         }
      }
      if($Passthru) { return $global:current }
   }
   "ByTitle" {
      [int]$global:result = -1
      [int]$global:current = -1
      $null = Invoke-BootsWindow $Window {
         # Figure out where we are now...
         $global:current = @($global:Frame.BackStack.GetEnumerator()).Count
         # Start with backward history ('cause it's more likely)
         [int]$i = 0;
         foreach($page in $global:Frame.BackStack) {
            if($page.Name -eq $Title) {
               $global:result = $current - $i - 1
               for(;$i -gt $0 -and $global:Frame.CanGoBack;$i--) {
                  $global:Frame.GoBack()
               }
               break;
            }
            $i++
         }
         # Failing that, try forward history
         [int]$i = 0;
         foreach($page in $global:Frame.ForwardStack) {
            if($page.Name -eq $Title) {
               $global:result = $current + $i + 1
               for(;$i -gt $0 -and $global:Frame.CanGoForward ;$i--) {
                  $global:Frame.GoForward()
               }
               break;
            }
            $i++
         }
      }
      if($Passthru) {
         if($global:result -ge 0) {
            return $global:result
         } else {
            return $global:current
         }
      }
   }
}
}
New-Alias Set-Slide Show-Slide # backwards compat

function Move-NextSlide {
#.Synopsis
#  Navigates to the next slide (if there is another)
PARAM(
   [Parameter()]
   $Window = $presentationTitle
,
   [Parameter()]
   [Switch]$Passthru
) 
   $DidGo = Invoke-BootsWindow $Window {
      Write-Output $global:Frame.CanGoForward
      if($global:Frame.CanGoForward) {
         $global:Frame.GoForward()
      }
   }
   if($Passthru){ $DidGo }
}
New-Alias Next-Slide Move-NextSlide # backwards compat

function Move-PreviousSlide {
#.Synopsis
#  Navigates to the previous slide (if there is another)
PARAM(   
   [Parameter()]
   $Window = $presentationTitle
,
   [Parameter()]
   [Switch]$Passthru
) 
   $DidGo = Invoke-BootsWindow $Window {
      Write-Output $global:Frame.CanGoForward
      if($global:Frame.CanGoBack) {
         $global:Frame.GoBack()
      }
   }
   if($Passthru){ $DidGo }
}
New-Alias Prev-Slide Move-PreviousSlide
New-Alias Previous-Slide Move-PreviousSlide # backwards compat

function Start-Presentation {
#.Synopsis
#  Start a presentation window
#.Description
#  This is the kick-off function you have to call to create the presentation window
PARAM(
   $PresentationTitle = "PowerShell Presentation"
,  $BackgroundImagePath = $(Get-ItemProperty "HKCU:\Control Panel\Desktop" | Select -Expand Wallpaper | Get-ChildItem)
)

   $BackgroundImagePath = Convert-Path (Resolve-Path $BackgroundImagePath)
   $global:PresentationTitle = $PresentationTitle
   ## Finally, make the slide window
   Boots -Title $PresentationTitle `
         -Height $([System.Windows.SystemParameters]::PrimaryScreenHeight) `
         -Width $([System.Windows.SystemParameters]::PrimaryScreenWidth)   `
   { 
      $global:TitleBrush = LinearGradientBrush -Start "0.5,0" -End "0.5,1" {
         GradientStop -Color "#FF084670" -Offset 0
         GradientStop -Color "#FF084670" -Offset 0.6
         GradientStop -Color "#FF000000" -Offset 0.6
      }
      $global:Frame = Frame -Content {
         Page -Title "Welcome" {
            Grid {
               TextBlock $PresentationTitle `
                  -FontSize 125 -FontFamily Impact -Foreground White `
                  -VerticalAlignment Center -TextAlignment Center    `
                  -HorizontalAlignment Stretch -TextWrapping Wrap    `
                  -Effect { BlurEffect -Radius 30 }
               TextBlock $PresentationTitle `
                  -FontSize 125 -FontFamily Impact -Foreground White `
                  -VerticalAlignment Center -TextAlignment Center    `
                  -HorizontalAlignment Stretch -TextWrapping Wrap    `
                  -Effect { BlurEffect -Radius 30 }
            
               TextBlock $PresentationTitle `
                     -FontSize 125 -FontFamily Impact -Foreground $global:TitleBrush `
                     -VerticalAlignment Center -TextAlignment Center  `
                     -HorizontalAlignment Stretch -TextWrapping Wrap  `
            }
         }
      }
      #Start-Zoom -Root $global:Frame
      $global:Frame
   } -Async -On_SourceInitialized { 
        if(Test-Path $BackgroundImagePath) {
           $this.Background = ImageBrush -ImageSource $BackgroundImagePath
        }
      $this.WindowState = "Maximized"
   } -On_KeyDown {
      trap { Write-Host $( $_ | fl * | Out-String ) }
      switch -regex ($_.Key) {
         "Escape" { 
            Set-Zoom 0; break;
         }
         "OemPlus|Add" { 
            Set-Zoom +1; break;
         }
         "OemMinus|Subtract" {
            Set-Zoom -1; break;
         }
         "MediaNextTrack|BrowserForward|Right" {
            Next-Slide; break;
         }
         "MediaPreviousTrack|BrowserBack|Left" {
            Previous-Slide; break;
         }
      }
   } -On_MouseWheel {
      if($_.Delta -gt 0 ) {
         Set-Zoom +1
      } else {
         Set-Zoom -1
      }
      
   }
   
   # -WindowStyle None -AllowsTransparency $true

}

function Test-Presentation {
   Start-Presentation "PowerShell for Developers"
   
   Add-TextSlide "Overview" "What is PowerShell?", "How can it help me?", "Should I code for it?", "How do I ..."
   Add-TextSlide "What is PowerShell?" "A .Net Console","A new .Net Language","An admin scripting tool","An app automation engine", "All of the above"
   ls ~\Pictures\Comix | Add-Slide

   Set-Slide 0
   
   ## The simple, automatic, force-my-hand slide timer.
   ## One slide, every 20 seconds:
   ## go forward and check if we can go forward again
   while( Move-NextSlide -Passthru ) {
      # note that we have to sleep outside the invoke... 
      # otherwise the window can't update
      sleep 20
   }
   
}

Export-ModuleMember -Function * -Alias *
