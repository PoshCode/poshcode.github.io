
Function New-TextIcon {
    [CmdletBinding()] 
	Param(
        	[Parameter(Mandatory=$true)] 
        	[string]$Text,
        	[string]$Path,
        	[int]$Height = 16,
        	[int]$Width = 16,
		[int]$FontSize = 9
	)
   
    DynamicParam  {
		[void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
		$fontlist = (New-Object System.Drawing.Text.InstalledFontCollection).Families
		$stylelist = [System.Enum]::GetNames([System.Drawing.FontStyle])
		$colorlist = [System.Enum]::GetNames([System.Drawing.KnownColor])
		
		$attributes = New-Object System.Management.Automation.ParameterAttribute
		$attributes.ParameterSetName = "__AllParameterSets"
		$attributes.Mandatory = $false
    
        # Font family
		$validationset = New-Object -Type System.Management.Automation.ValidateSetAttribute -ArgumentList $fontlist
		$collection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
		$collection.Add($attributes)
		$collection.Add($validationset)
		$fontname = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("FontName", [String], $collection)
        $fontname.Value = "Helvetica"

        # Font style
		$validationset = New-Object -Type System.Management.Automation.ValidateSetAttribute -ArgumentList $stylelist
		$collection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
		$collection.Add($attributes)
		$collection.Add($validationset)
		$fontstyle = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("FontStyle", [String], $collection)
        $fontstyle.Value = "Regular"
 
        # Background color
		$validationset = New-Object -Type System.Management.Automation.ValidateSetAttribute -ArgumentList $colorlist
		$collection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
		$collection.Add($attributes)
		$collection.Add($validationset)
		$background = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("Background", [String], $collection)
        $background.Value = "Transparent"
            
        # Background color
		$validationset = New-Object -Type System.Management.Automation.ValidateSetAttribute -ArgumentList $colorlist
		$collection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
		$collection.Add($attributes)
		$collection.Add($validationset)
		$foreground = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("Foreground", [String], $collection)     
		$foreground.Value = "White"
            
		$newparams = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
		$newparams.Add("FontName", $fontname)
		$newparams.Add("FontStyle", $fontstyle)
		$newparams.Add("Background", $background)
		$newparams.Add("Foreground", $foreground)
	
	return $newparams
	}

    PROCESS {
        
        $fontname = $fontname.value; $fontstyle = $fontstyle.value; 
        $background = $background.value; $foreground = $foreground.value
  
        $fontstyle = [System.Drawing.FontStyle]::$fontstyle
        $background = [System.Drawing.Brushes]::$background
        $foreground = [System.Drawing.Brushes]::$foreground
        
        $bmp = New-Object System.Drawing.Bitmap $width,$height
        $font = New-Object System.Drawing.Font($fontname,$fontsize,$fontstyle)
        $graphics = [System.Drawing.Graphics]::FromImage($bmp) 
        $graphics.FillRectangle($background,0,0,$wsWidth,$height)
        
        $graphics.DrawString($text,$font,$foreground,0,0)
        $graphics.Dispose()
        if ($Path.Length -gt 0) {
            $ext = ([System.IO.Path]::GetExtension($Path)).TrimStart(".")
            $null = $bmp.Save($path, $ext) 
        }
        $icon = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
        return $icon
    }
}

# Sample to add to, say a NotifyIcon
$icon = New-TextIcon -Path C:\temp\test.png -Text "#1" -FontSize 8
$notify= New-Object System.Windows.Forms.NotifyIcon 
$notify.Icon =  $icon

# See results (Note that Path is optional! This was originally written to allow streaming to a NotifyIcon
Invoke-Item C:\temp\test.png
