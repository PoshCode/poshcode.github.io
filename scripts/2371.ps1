######## CSV DATA #############
# Save the following data to a csv.


City,Team
"Los Angeles","Lakers"
"Los Angeles","Clippers"
"New York","Knicks"
"New York","Liberty"
"Sacramento","Kings"
 
######## CODE #################
 
$teams = Import-Csv "C:\testdata.csv"


[array]$cities = $teams | %{$_.City} | Sort -Unique


[Object[]]$test = foreach ($city in $cities){
        New-Object psobject -Property @{
                City = $city
                Teams = @(foreach($team in $($teams | ?{$_.City -eq $city} | %{$_.Team} | Sort -Unique)){
                        New-Object psobject -Property @{
                        Team = $Team
                        IsSelected = "True"
                        }
                })
        }
}
 
Import-Module PowerBoots

# Xaml layout -- this is where binding is set.
$xaml = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="Window">
        <Grid>
                <TreeView Name="treeview1">
                        <TreeView.ItemTemplate>
                                <HierarchicalDataTemplate ItemsSource="{Binding Teams}">
                                        <TextBlock Foreground="Green" Text="{Binding City}" />
                                        <HierarchicalDataTemplate.ItemTemplate>
                                                <DataTemplate>
                                                        <StackPanel Orientation="Horizontal">
                                                                <TextBlock Text="{Binding Team}" />
                                                                <CheckBox IsChecked="{Binding IsSelected}" IsEnabled="False"/>
                                                        </StackPanel>
                                                </DataTemplate>
                                        </HierarchicalDataTemplate.ItemTemplate>
                                  
                                </HierarchicalDataTemplate>
                        </TreeView.ItemTemplate>
                </TreeView>
        </Grid>
</Window>
"@
 
$MainWindow= New-BootsWindow -Title "Treeview Binding" -Width 100 -Height 150 -SourceTemplate $xaml -Async -Passthru -On_Loaded {
        Export-NamedElement
        $treeView1.ItemsSource = $test
}
