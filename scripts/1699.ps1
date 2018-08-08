function Format-PoshTable {
#.Synopsis
#  Format-PoshTable puts the output in a WPF DataGrid (inline in PoshConsole)
#.Description 
#  Outputs a WPF datagrid of the objects (and properties) specified. 
#  This grid can be sorted, rearranged, etc
	[CmdletBinding()]
	param(
      [parameter(ValueFromPipeline=$true)]
      [Array]$InputObject
   ,
      [Parameter(Position=1)]
      [String[]]$Property = "*"
   ,
      [Parameter(Position=2)][Alias("Type")]
      [Type]$BaseType # a type to use as the generic in the collection
   ,
      [Parameter()]
      [Switch]$Popup = (![bool]$Host.PrivateData.WpfConsole)
	)
	Begin
	{
      $global:theFormatPoshTableDataGrid = $null
		if (!(Get-Command datagrid) )
		{
			Import-Module PowerBoots
         Add-BootsFunction 'C:\Program Files (x86)\WPF Toolkit\*\WPFToolkit.dll'
		}
	}
	Process
	{
      # Create the window here instead of in BEGIN because we need to know the TYPE for the datagrid
		if(!$global:theFormatPoshTableDataGrid) {
         if(!$BaseType) { $BaseType = $InputObject[0].GetType().FullName }
         # We're going to create a special collection ... 
			$global:ObservableCollection = new-object System.Collections.ObjectModel.ObservableCollection[$BaseType]
         foreach($i in $InputObject) { $ObservableCollection.Add($i) > $null }
         boots {
            Param($ItemCollection, $Property)
				datagrid -RowBackground "AliceBlue" -AlternatingRowBackground "LightBlue" -On_AutoGeneratingColumn {
               Param($Source,$SourceEventArgs) 
               $header = $SourceEventArgs.Column.Header.ToString()
               $Cancel = $true
               # If it matches any of the properties, don't cancel it.
               foreach($h in $Source.Tag) {  if($header -like $h) {  $Cancel = $false } }
               $SourceEventArgs.Cancel = $Cancel
            }  -ColumnHeaderStyle {
					Style -Setters {
						Setter -Property ([System.Windows.Controls.ListView]::FontWeightProperty) -Value ([System.Windows.FontWeights]::ExtraBold)
					}
				} -ItemsSource $ItemCollection -ov global:theFormatPoshTableDataGrid -tag $Property
         } $ObservableCollection $Property -Inline:(!$Popup) -Popup:$Popup
		} else {
         @($global:theFormatPoshTableDataGrid)[0].Dispatcher.Invoke( "Normal", ([Action]{  foreach($i in @($InputObject)) { $global:ObservableCollection.Add($i) > $null } }) )  
		}
	}
}
