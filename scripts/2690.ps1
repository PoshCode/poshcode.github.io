ipmo WPK
Function Get-TechEDSession {                

    $url = "https://channel9.msdn.com/Events/TechEd/NorthAmerica/2011/RSS/"
    $wc   = New-Object net.webclient
    #$wc.Proxy.Credentials = Get-Credential
    $feed = ([xml]($wc.downloadstring($url))).rss.channel.item            

    $feed | ForEach {
                New-Object PSObject -Property @{
                Title = $_.title
                Url = $_.Enclosure.url
                Category = @($_.Category)
            }
    }
}                        

$sessions = Get-TechEDSession
New-Window -Title "TechED - NA 2011 Session viewer" -WindowStartupLocation CenterScreen -Width 1200 -Height 600 -On_Loaded {
    $lstBox = $window | Get-ChildControl lstBox
    $lstBox.ItemsSource = $sessions
} {
    New-Grid -Rows 32, 1* -Columns 300, 900* {                        

        New-ComboBox -Name cmbBox -MaxHeight 400 -MaxWidth 300 -ItemsSource @($sessions | Select -ExpandProperty Category -Unique) -On_SelectionChanged {
            $lstBox = $window | Get-ChildControl lstBox
            $lstBox.ItemsSource = @($sessions | ? { $_.Category -Contains $this.SelectedValue})
        }                        

        New-ListBox -Name lstBox -Row 1 -Column 0 -DisplayMemberPath Title -On_SelectionChanged {
                $wplayer = $window | Get-ChildControl player
                $wplayer.Source = $this.SelectedItem.Url
            }                        

        New-MediaElement -Name player -Column 1 -RowSpan 2
    }
} -Show
