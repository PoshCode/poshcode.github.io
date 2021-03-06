ipmo PowerBoots # Require PowerBoots

## More readable:
New-BootsWindow { 
   ScrollViewer { 
      StackPanel { 
         ForEach($font in (New-Object Drawing.Text.InstalledFontCollection).Families | Select -Expand Name) {
            TextBlock "$font -- The brown fox (quickly) jumps over the ""lazy"" dog, 123456789" -FontFamily $font -FontSize 16 -Tooltip $font
         }
      }
   }
} -Width 800 -Height 900


return
## One-liner:
New-BootsWindow { (New-Object Drawing.Text.InstalledFontCollection).Families | %{ Label "$($_.Name) -- The brown fox (quickly) jumps over the ""lazy"" dog, 123456789" -FontFamily $_.Name -FontSize 16 -Tooltip $_.Name } | StackPanel | ScrollViewer } -Width 800 -Height 900
