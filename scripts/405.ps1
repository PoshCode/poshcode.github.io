#requires -version 2.0
### Import the WPF assemblies
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Set-PSDebug -Strict

## Select-Grid
##   Displays objects in a grid view and returns (only) the selected ones when closed.
########################################################################################################################
## Usage:
##   ls | Select-Grid Name, Length, Mode, LastWriteTime
##   ps | Select-Grid ProcessName, Id, VM, WS, PM, Product, Path
##   Select-Grid Name, Length, Mode, LastWriteTime -Input (ls)
##  
## Take advantage of the graphing:
##   ls | Select-Grid Name,Length,LastModifiedTime,Mode -Title $pwd -Sort Length -Graph Length
## Kill the selected processes:
##   ps | Select-Grid ProcessName, Id, VM, WS, PM, Product, Path -Title "Processes" -Sort WS -Graph VM,WS,PM | kill
########################################################################################################################
## History:
## v3.1 - Fixed a bug with not passing the graph parameter
## v3.0 - Added CellTemplate for graphing (first release to PowerShellCentral.com/scripts)
## v2.5 - Added Multi-select and made it output the selected items
## v2.3 - Added Title and made columns dragable
## v2.2 - Fixed pipeline problems
## v2.1 - Added "Get-Default" to populate blank rows
## v2.0 - Added clickable headers and sorting 
##     -- broken on columns with blanks?
## v1.0 - Basic grid with data-binding 
##     -- broken on pipeline
########################################################################################################################
Cmdlet Select-Grid -ConfirmImpact low -snapin Huddled.WPF
{
   Param (
      [Parameter(Position=0)][string[]]$Properties,
      [Parameter(Position=1)][string[]]$Title,
      [Parameter(Position=2)][string[]]$Sort,
      [Parameter(Position=3)][string[]]$Graph,
      [Parameter(Mandatory=$true, ValueFromPipeline=$true)] $InputObjects
   )
   BEGIN {   
      if ($CommandLineParameters.ContainsKey("InputObjects")) {
         $outputObjects = @(,$InputObjects)
      } else {
         $outputObjects = @()
      }      
   }
   PROCESS {
      ### Collect together all input objects
      $outputObjects += $InputObjects
   }
   END {
      ### Create our window and listview
      $window = New-Object System.Windows.Window
      $window.SizeToContent = "WidthAndHeight"
      $window.SnapsToDevicePixels = $true
      $window.Content = New-Object System.Windows.Controls.ListView
      if($Title) {
         $window.Title = $Title
      } else { 
         $window.Title = $outputObjects[-1].GetType().Name
      }
      ### The ListView takes ViewBase object which controls the layout and appearance
      ### We'll use a GridView
      $window.Content.View = New-Object System.Windows.Controls.GridView
      $window.Content.View.AllowsColumnReorder = $true

      $columns = Get-PropertyTypes $outputObjects ([ref]$Properties)
      
      ### Make columns (use Properties instead of Columns.Keys to preserve order)
      foreach($Name in $Properties) {
         ### Try to ensure that every object has _some_ value for each column (so sorting works)
         $outputObjects | add-member -Type NoteProperty -Name $Name -value (Get-DefaultValue($columns[$name])) -ea SilentlyContinue

         ## For each property, make a column         
         $gvc = New-Object System.Windows.Controls.GridViewColumn
         ## And bind the data ... 
         $gvc.DisplayMemberBinding = New-Object System.Windows.Data.Binding $Name
         ## In order to add sorting, we need to create the header ourselves
         $gvc.Header = New-Object System.Windows.Controls.GridViewColumnHeader
         $gvc.Header.Content = $Name
   
         ## Add a click handler to enable sorting ...
         $gvc.Header.add_click({
            $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $outputObjects )
            $sd = new-object System.ComponentModel.SortDescription $this.Content, $(
               if($view.SortDescriptions[0].PropertyName -eq $this.Content)  {
                  switch($view.SortDescriptions[0].Direction) {
                     "Ascending"  { "Descending" } "Descending" { "Ascending"  }
                  }} else { "Ascending" } )
            $view.SortDescriptions.Clear()
            $view.SortDescriptions.Add($sd)
            # if($view.SortDescriptions.Count -gt 2) { $view.SortDescriptions.RemoveAt(2) }
            $view.Refresh()
         })
         # Format-Column-Conditionally $obj, $Name, $gvc
         ## Use that column in the view
         $window.Content.View.Columns.Insert($window.Content.View.Columns.Count,$gvc)
      }

      $Graph = @($Graph | Where-Object { $Properties -contains $_ })
      if( $Graph.Count -gt 0 ) { 
         FormatColumn-Percent $outputObjects $window.Content.View $Graph
      }
      
      ## Databind the argument
      $window.Content.ItemsSource = $outputObjects
      
      ## Add an initial sort ...
      $sd = new-object System.ComponentModel.SortDescription
      $sd.PropertyName = &{ if($Sort) { $Sort }else{ $Properties[0] } }
      $sd.Direction = "Descending"
      [System.Windows.Data.CollectionViewSource]::GetDefaultView( $outputObjects ).SortDescriptions.Add($sd)

      ## Show the window
      $Null = $window.ShowDialog()
      $window.Content.SelectedItems
   }
}

## return a hash of property names and maximum values for each
function Get-Max($collection,$properties) {
   $max = @{}
   $collection | Measure-Object $properties -Max | ForEach-Object { $max[$($_.Property)] = $($_.Maximum)}
   return $max
}

## a quick and easy function to create default-value instances of any type
function Get-DefaultValue([type]$type) {
   if( $type.IsValueType) { 
      [Activator]::CreateInstance($type)
   } else { 
      $null 
   }
}

function Get-PropertyTypes($outputObjects, [ref]$Properties) {
   ### Collect the columns we're going to use 
   $columns = @{}
   ### if we have a list, use all the items on the list that are defined
   if($Properties.Value) {
      $Properties.Value = $outputObjects | Get-Member $Properties.Value -type Properties | ForEach-Object { $_.Name }
   } else {
      ### if we don't have a list, make one, from all the items...
      $Properties.Value = $outputObjects | Get-Member -type Properties | ForEach-Object { $_.Name }
   }
   ### Figure out the types
   ForEach($Name in $Properties.Value) { 
   $columns[$name] = $Null
      ForEach($obj in $outputObjects) { 
         if( $obj.($Name) ) {
            $columns[$name] = $obj.($Name).GetType()  
            break;
         }
      }
   }
   return $columns
}

#############################################################
## Conditionally format the columns ...
function FormatColumn-Percent( $outputObjects, $gridview,  $properties)
{
   # Calculate the max values 
   $max = Get-Max $outputObjects $properties
   # And finally, set the CellTemplace on those columns...
   foreach($property in $properties) {
      # And then calculate the percentages, based on that...
      # $outputObjects.Value | Add-Member ScriptProperty "$($property)Percent" {(`$this.${property} -as [int]) / $($max.($property))}
      # $outputObjects | Add-Member ScriptProperty "$($property)Percent" $executioncontext.InvokeCommand.NewScriptBlock(
                                                                       # "(`$this.$($property) -as [double]) / $($max.($property))")
      foreach($obj in $outputObjects) {
         Add-Member NoteProperty "$($property)Percent" (($($obj.$($property)) -as [double]) / $($max.($property))) -input $obj
      }

      $column = @($gridview.Columns | ? { $_.Header.Content -eq $property })[0];
      ## dump the binding and use a template instead... (this shouldn't be necessary)...
      $column.DisplayMemberBinding = $null
      $column.CellTemplate = `
      [Windows.Markup.XamlReader]::Load( 
         (New-Object System.Xml.XmlNodeReader (
         [Xml]"<DataTemplate xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'>
                  <Grid>
                     <Rectangle Margin='-6,0' VerticalAlignment='Stretch' RenderTransformOrigin='0,1' >
                        <Rectangle.Fill>
                           <LinearGradientBrush StartPoint='0,0' EndPoint='1,0'>
                              <GradientStop Color='#FFFF4500' Offset='0' />
                              <GradientStop Color='#FFFF8585' Offset='1' />
                           </LinearGradientBrush>
                        </Rectangle.Fill>
               			<Rectangle.RenderTransform>
                           <ScaleTransform ScaleX='{Binding $($property)Percent}' ScaleY='1' />
                   		</Rectangle.RenderTransform>              
                     </Rectangle>              
                     <TextBlock Width='100' Margin='-6,0' TextAlignment='Right' Text='{Binding $property}' />
                  </Grid>
               </DataTemplate>")))
   }
}

