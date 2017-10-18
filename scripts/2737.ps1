New-Grid -ControlName SelectUserGroups -Columns Auto,* -Rows 4 {
    $GetGroups = { 
        $user = Get-QADUuser $this.Text -SizeLimit 1
        if($User.LogonName -eq $this.Text -or $User.Email -eq $this.Text) {
            $this.Foreground = "Black" 
            $Group.ItemsSource = Get-QADGroup -ContainsMember $user
            $UserName.Text = $user.LogonName
            $EmailAddress.Text = $user.Email
        } else {
            $this.Foreground = "Red" 
            $Group.ItemsSource = @()         
        }
    }
    
    New-Label "Name"
    New-Textbox -name UserName -minwidth 100 -Column 1 -On_LostFocus $GetGroups
    
    New-Label "Email" -Row 1
    New-Textbox -name EmailAddress -minwidth 100  -Column 1 -Row 1  -On_LostFocus $GetGroups
    
    New-Label "Group" -Row 2
    New-Listbox -name Group -Column 1 -Row 2
    
    New-Button "OK" -Row 3 -Column 1 -On_Click { Get-ParentControl | Set-UIValue -Passthru | Close-Control }
} -Show
