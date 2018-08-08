# FormsLib.ps1
# contains some helper functions to create and modify Form controls
# in a PowerShell script used by RoboGUI.ps1
#
# /\/\o\/\/
# http://thePowerShellGuy.com 

Function ConvertTo-HashTable ([string]$StringValue) {
  invoke-expression ("@$StringValue".replace(',',';')) 
}

Function ConvertTo-Point ([string]$StringValue) {
  ConvertTo-HashTable $StringValue |
      % {New-Object System.Drawing.Point([int]($_.x),[int]($_.y))}
}

Function ConvertTo-Size ([string]$StringValue) {
  ConvertTo-HashTable $StringValue |
      % {New-Object System.Drawing.Size([int]($_.Width),[int]($_.Height))}
}


filter get-PropertyList {  
  $o = $_ ; $_ | gm -MemberType Property | 
    select name, 
      @{Name='Type';Expression={$_.definition.split()[0]}},
      @{Name='Value';Expression={$o."$($_.name)"}}
}

Function Get-ControlFormat {
  Param (
    $Control,
    $properties = ('Text','Size','Location','Dock','Anchor'),
    $ExtraProperties
  ) 
  $properties += $ExtraProperties
  "Set-ControlFormat `$$($Control.name) ``"
  $Control | get-PropertyList |
    Where {$Properties -contains $_.name} |
      Foreach  {
        "  -$($_.name) '$($_.Value)'``"
      }
}

Function Set-ControlFormat {
  Param  (
    $Control
  )
  foreach ($arg in $args) {
    if ($arg.startswith('-')) {
      $Property = $arg.trim('-')
      [void] $foreach.MoveNext()
      Switch ($Property) {
        'Location' { $Control.Location = ConvertTo-Point $foreach.current ; break}
        'Size' { $Control.Size = ConvertTo-Size $foreach.current ; break}
        Default {$Control."$Property" = $foreach.current}
      }
    }
  }
}


Function get-FormControls ($psObject) {
  $form = new-object Windows.Forms.Form
  $form.Size = new-object Drawing.Size @(600,600)
  $controls = @("form") 
  $psObject.Controls |% {$controls += $_.name}
  $CB = new-object Windows.Forms.Combobox
  $cb.Size = new-object Drawing.Size @(500,21)
  $cb.Items.AddRange($controls)
  $PG = new-object Windows.Forms.PropertyGrid
  $PG.Size = new-object Drawing.Size @(500,500)
  $PG.Location = New-Object System.Drawing.Point(50 , 50)
  $form.text = "$psObject"
  $PG.selectedobject = $psObject.PsObject.baseobject
  $cb.text = 'form'
  $cb.add_TextChanged({
    if ( $this.SelectedItem -eq 'Form') {
      $PG.selectedobject = $psObject.PsObject.baseobject
    } Else {
      $PG.selectedobject = $psObject.Controls["$($this.SelectedItem)"].PsObject.baseobject
    }
  })
  $form.Controls.Add($PG)
  $form.Controls.Add($CB)
  $Form.Add_Shown({$form.Activate()})
  $form.showdialog()
}
