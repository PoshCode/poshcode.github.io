if ($host.Runspace.ApartmentState -ne 'STA') {
  powershell /noprofile /sta $MyInvocation.MyCommand.Path
  return
}

[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="Window"
        Height="300"
        ResizeMode="NoResize"
        ShowInTaskbar="False"
        Title="SigCheck"
        Width="610"
        WindowStartupLocation="CenterScreen">
  <StackPanel Orientation="Horizontal">
    <StackPanel Orientation="Vertical">
      <Label Content="Search:" />
      <TextBox x:Name="Input"
               AcceptsReturn="True"
               Height="19"
               Width="190" />
      <Label Content="Appearance:" />
      <ListBox x:Name="Matches"
               Height="201" />
    </StackPanel>
    <StackPanel Orientation="Vertical">
      <Label Content="Result" />
      <TextBox x:Name="Result"
               Height="210"
               HorizontalScrollBarVisibility="Visible"
               Margin="7, 0, 0, 0"
               VerticalScrollBarVisibility="Visible"
               Width="400" />
      <Button x:Name="Query"
              Content="Query"
              Height="23"
              Margin="0, 5, 0, 0"
              Width="75" />
    </StackPanel>
  </StackPanel>
</Window>
'@

function winMain_Show {
  Add-Type -AssemblyName PresentationFramework
  
  $win = [Windows.Markup.XamlReader]::Load(
    (New-Object Xml.XmlNodeReader $xaml)
  )
  
  $inp = $win.FindName('Input')
  $mat = $win.FindName('Matches')
  $res = $win.FindName('Result')
  $btn = $win.FindName('Query')
  
  $inp.Add_TextChanged({
    $res.Clear()
    $mat.ItemsSource = @(gcm -c Application "$($inp.Text)*")
  })
  
  $mat.Add_SelectionChanged({
    if (-not [String]::IsNullOrEmpty($mat.SelectedItem)) {
      $str = (gcm -c Application $mat.SelectedItem).Definition
    }
  })
  
  $btn.Add_Click({
    $res.Clear()
    $res.Text = (sigcheck -q -a -h -i $str | % {$_ + "`n"})
  })
  
  [void]$win.ShowDialog()
}

if (-not [String]::IsNullOrEmpty(
    (gcm -c Application | ? {$_.name -match 'sigcheck'}).Definition)
   ) {
  winMain_Show
}
else {
  Write-Warning 'Probably, sigcheck.exe has not been installed!'
  Write-Host Please, visit sysinternals.com to get it. -fo Cyan
  ""
}
