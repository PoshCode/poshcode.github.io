## Select-ViaGui.ps1
## Use a graphical interface to select (and pass-through) pipeline objects
## originally by Lee Holmes (http://www.leeholmes.com/blog), although he might not recognize it now ;-)
Import-Module ShowUI

## Get the item as it would be displayed by Format-Table
## Generate the window
Show-UI -Title "Object Filter" -MinWidth 400 -Height 600 {
   param($InputItems)
   Grid -Margin 5 -RowDefinitions Auto, *, Auto, Auto {

      # we need to store the original items ... so we can output them later
      # But we're going to convert them to strings to display them
      $StringItems = New-Object System.Collections.ArrayList
      # So, use a hashtable, with the strings as the keys to the original values 
      $originalItems = @{}

      ## Convert input to string representations and store ...
      foreach($item in $InputItems) {
         $stringRepresentation = (($item | ft -HideTableHeaders | Out-String )-Split"\n")[-4].trimEnd()
         $originalItems[$stringRepresentation] = $item
         $null = $StringItems.Add($stringRepresentation)
      }

      ## This is just a label ...
      TextBlock -Margin 5 -Grid-Row 0 {
         "Type or click to search. Press Enter or click OK to pass the items down the pipeline." 
      }
      
      ## Put the items in a ListBox, inside a ScrollViewer so it can scroll :)
      ScrollViewer -Margin 5 -Grid-Row 1 {
         ListBox -SelectionMode Multiple -ItemsSource $StringItems -Name SelectedItems `
                 -FontFamily "Consolas, Courier New" -On_MouseDoubleClick { 
                                        param($source,$e)
                                        $originalItems[$e.OriginalSource.DataContext] | Write-UIOutput
                                        $ShowUI.ActiveWindow.Close()
                                      }

      } 

      ## This is the filter box: Notice we update the filter on_KeyUp
      TextBox -Margin 5 -Name SearchText -Grid-Row 2 -On_KeyUp {
         $filterText = $this.Text
         $SelectedItems = Select-UIElement "Object Filter" SelectedItems
         [System.Windows.Data.CollectionViewSource]::GetDefaultView( $SelectedItems.ItemsSource ).Filter = [Predicate[Object]]{ 
            param([string]$item)
            ## default to true
            trap { return $true }
            ## Do a regex match
            $item -match $filterText
         }
      }

      ## An event handler for the OK button, to send the selected items down the pipeline
      function OK_Click
      {
          $selectedItems = Select-UIElement "Object Filter" SelectedItems
          $source = $selectedItems.Items

          if($selectedItems.SelectedItems.Count -gt 0)
          {
              $source = $selectedItems.SelectedItems
          }

          ## Use Write-UIOutput to send things out from the UI to the pipeline...
          $originalItems[$source] | Write-UIOutput
          $ShowUI.ActiveWindow.Close()
      }

      ## Use a GridPanel ... it's a simple, yet effective way to lay out a couple of buttons.
      GridPanel -Margin 5 -HorizontalAlignment Right -ColumnDefinitions 65, 10, 65 {
         Button "OK" -IsDefault -Width 65 -On_Click OK_Click -"Grid.Column" 0
         Button "Cancel" -IsCancel -Width 65 -"Grid.Column" 2
      } -"Grid.Row" 3 -Passthru
      ## Focus on the Search box by default
   } -On_Loaded { (Select-UIElement $this SearchText).Focus() }
   ## Don't forget to pass in the pipeline input
} -Args $input -Export

