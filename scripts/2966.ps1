#Import-Module showui
$Windowparam = @{
    Width = 500
    Height = 400
    Title = 'Fun Text Converter'
    Background = '#C4CBD8'
    WindowStartupLocation = 'CenterScreen'
    AsJob = $True
}

#Create Window
New-Window @Windowparam {
    New-Grid -Rows *,Auto,*,Auto -Children {
        New-TextBox -Row 0 -Name InputBox -TextWrapping Wrap -VerticalScrollBarVisibility Auto
        New-Grid -Row 1 -Columns *,*,Auto,Auto,Auto,*,* -Children {
            New-Button -Column 2 -Name ConvertButton -Width 65 -Height 25 -Content Translate -On_Click {
                If ($ComboBox.Text -eq 'TextToBinary') {
                    $OutputBox.Text = Convert-TextToBinary $InputBox.Text
                } ElseIf ($ComboBox.Text -eq 'BinaryToText') {
                    $OutputBox.Text = Convert-BinaryToText $InputBox.Text
                } ElseIf ($ComboBox.Text -eq 'TextToHex') {
                    $OutputBox.Text = Convert-TextToHex $InputBox.Text
                } ElseIf ($ComboBox.Text -eq 'HexToText') {
                    $OutputBox.Text = Convert-HexToText $InputBox.Text
                } ElseIf ($ComboBox.Text -eq 'BinaryToHex') {
                    $OutputBox.Text = Convert-BinaryToHex $InputBox.Text
                } ElseIf ($ComboBox.Text -eq 'HexToBinary') {
                    $OutputBox.Text = Convert-HexToBinary $InputBox.Text
                } ElseIf ($ComboBox.Text -eq 'ReverseInput') {
                    $OutputBox.Text = Convert-TextToReverseText $InputBox.Text
                }
            }
            New-Label -Column 3
            New-ComboBox -Name ComboBox -Column 4 -IsReadOnly:$True -SelectedIndex 0 -Items {
                New-TextBlock -Text TextToBinary
                New-TextBlock -Text BinaryToText
                New-TextBlock -Text TextToHex
                New-TextBlock -Text HexToText
                New-TextBlock -Text BinaryToHex
                New-TextBlock -Text HexToBinary
                New-TextBlock -Text ReverseInput
            }
        }
        New-TextBox -Row 2 -Name OutputBox -IsReadOnly:$True -TextWrapping Wrap `
        -VerticalScrollBarVisibility Auto
        New-StackPanel -Row 3 -Orientation Horizontal {
            New-Button -Name CopyTextButton -Width 65 -Height 25 -HorizontalAlignment Left -Content CopyText  -On_Click {
                $OutputBox.text | clip
            }
            New-Label
            New-Button -Name ClearTextButton -Width 65 -Height 25 -HorizontalAlignment Left -Content ClearText -On_Click {
                $OutputBox.Text=$Null
            }
        }
    }
} -On_Loaded {
    Function Convert-TextToBinary {
        [cmdletbinding()]
        Param (
            [parameter(ValueFromPipeLine='True')]    
            [string]$Text
        )
        Begin {
            #Create binary empty collection
            [string[]]$BinaryArray = @()
        }
        Process {
            #Convert text to array
            $textarray = $text.ToCharArray()
            
            #Convert each item to binary
            ForEach ($a in $textarray) {
                $BinaryArray += ([convert]::ToString([int][char]$a,2)).PadLeft(8,"0")
            }
        }
        End {
            #Write out binary string
            $BinaryArray -Join " "
        }
    }

    Function Convert-BinaryToText {
        [cmdletbinding()]
        Param (
            [parameter(ValueFromPipeLine='True')]
            [string]$Binary
        )
        Begin {
            #Create binary empty collection
            [string[]]$TextArray = @()        
        }
        Process {
            #Split Binary string into array
            $BinaryArray = $Binary -split "\s"
            
            #Convert each item to Char
            ForEach ($a in $BinaryArray) {
                $TextArray += [char]([convert]::ToInt64($a,2))
            }
        }
        End {
            #Write out text string
            $TextArray -Join ""        
        }
    }
    Function Convert-TextToHex {
        [cmdletbinding()]
        Param (
            [parameter(ValueFromPipeLine='True')]    
            [string]$Text
        )
        Begin {
            #Create hex empty collection
            [string[]]$HexArray = @()
        }
        Process {
            #Convert text to array
            $textarr = $text.ToCharArray()
            
            #Convert each item to binary
            ForEach ($a in $textarr) {
                $HexArray += "0x$(([convert]::ToString([int][char]$a,16)).PadLeft(8,'0'))"
            }
        }
        End {
            #Write out hex string
            $HexArray -Join " "
        }
    }

    Function Convert-HexToText {
        [cmdletbinding()]
        Param (
            [parameter(ValueFromPipeLine='True')]
            [string]$Hex
        )
        Begin {
            #Create text empty collection
            [string[]]$textarr = @()        
        }
        Process {
            #Split Binary string into array
            $HexArray = $Hex -split "\s"
            
            #Convert each item to Char
            ForEach ($a in $HexArray) {
                $textarr += [char]([convert]::ToInt64($a.TrimStart('x0'),16))
            }
        }
        End {
            #Write out text string
            $textarr -join "" 
        }
    }       

    Function Convert-HexToBinary {
        [cmdletbinding()]
        Param (
            [parameter(ValueFromPipeLine='True')]
            [string]$Hex
        )
        Begin {
            #Create binary empty collection
            [string[]]$binarr = @()        
        }
        Process {
            #Split Binary string into array
            $HexArray = $Hex -split "\s"
            
            #Convert each item to Char
            ForEach ($a in $HexArray) {
                $a = ([char]([convert]::ToInt64($a.TrimStart('x0'),16)))
                $binarr += ([convert]::ToString([int][char]$a,2)).PadLeft(8,"0")
            }
        }
        End {
            #Write out binary string
            $binarr -join " "     
        }
    }

    Function Convert-BinaryToHex {
        [cmdletbinding()]
        Param (
            [parameter(ValueFromPipeLine='True')]
            [string]$Binary
        )
        Begin {
            #Create binary empty collection
            [string[]]$TextArray = @()        
        }
        Process {
            #Split Binary string into array
            $BinaryArray = $Binary -split "\s"
            
            #Convert each item to Char
            ForEach ($a in $BinaryArray) {
                $a = [char]([convert]::ToInt64($a,2))
                $TextArray += "0x$(([convert]::ToString([int][char]$a,16)).PadLeft(8,'0'))"
            }
        }
        End {
            #Write out hex string
            $TextArray -Join " "     
        }
    }     

    Function Convert-TextToReverseText {
        [cmdletbinding()]
        Param (
            [parameter(ValueFromPipeLine='True')]    
            [string]$InputString
        )
        Begin {
        }
        Process {
            #Convert text to array
            $inputarray = $InputString -split ""
        
            #Reverse array
            [array]::Reverse($inputarray)
        }
        End {
            #Write out reverse string
            $inputarray -join ""
        }
    }
}
