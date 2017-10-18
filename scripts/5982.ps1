$folder = "$env:userprofile\pictures"
$wait = 10

function New-PInvoke
{
  <#

    .Synopsis
      Generate a powershell function alias to a Win32|C api function
    .Description
      Creates C# code to access a C function, and exposes it via a powershell function
    .Example
      New-PInvoke user32 "void FlashWindow(IntPtr hwnd, bool bInvert)"

Generates a function for FlashWindow which ignores the boolean return value, and allows you to make a window flash to get the user's attention. Once you've created this function, you could use this line to make a PowerShell window flash at the end of a long-running script:
        C:\PS>FlashWindow (ps -id $pid).MainWindowHandle $true
    .Parameter Library
        A C Library containing code to invoke
    .Parameter Signature
        The C# signature of the external method
    .Parameter OutputText
        If Set, retuns the source code for the pinvoke method.
        If not, compiles the type. 
    #>
    param(
    [Parameter(Mandatory=$true, 
        HelpMessage="The C Library Containing the Function, i.e. User32")]
    [String]
    $Library,

    [Parameter(Mandatory=$true,
        HelpMessage="The Signature of the Method, i.e.: int GetSystemMetrics(uint Metric)")]
    [String]
    $Signature,

    [Switch]
    $OutputText
    )

    process {
        if ($Library -notlike "*.dll*") {
            $Library+=".dll"
        }
        if ($signature -notlike "*;") {
            $Signature+=";"
        }
        if ($signature -notlike "public static extern*") {
            $signature = "public static extern $signature"
        }
        $name = $($signature -replace "^.*?\s(\w+)\(.*$",'$1')

        $MemberDefinition = "[DllImport(`"$Library`")]`n$Signature"

        if (-not $OutputText) {
            $type = Add-Type -PassThru -Name "PInvoke$(Get-Random)" -MemberDefinition $MemberDefinition
            del -ea 0 Function:Global:$name
            iex "New-Item Function:Global:$name -Value { [$($type.FullName)]::$name.Invoke( `$args ) }"
        } else {
            $MemberDefinition
        }
    }
}

new-pinvoke kernel32 "int SetThreadExecutionState(uint state)"

[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
$form = new-object Windows.Forms.Form
$form.Text = "Image Viewer"
$form.WindowState= "Maximized"
$form.controlbox = $false
$form.formborderstyle = "0"
$form.BackColor = [System.Drawing.Color]::black
$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.dock = "fill"
$pictureBox.sizemode = 4
$form.controls.add($pictureBox)
$form.Add_Shown( { $form.Activate()} )
$form.Show()
$list=@()
do
{
	if ($list.count -eq 0) 
    	{ 
		[collections.arraylist]$list=@(dir -literalpath $folder * -include *.jpg, *.jpeg, *.bmp, *.png -recurse)
		if ($list.count -eq 0) {"No pictures. Exiting.";exit}
    	}
    	$fileindex = get-random $list.count	
	$file = (get-item -ea 0 $list[$fileindex].fullname)
	$list.removeat($fileindex)
	if ($file -eq $null -or $file.fullname -eq "") {continue}
	
	"$($file.fullname)"
	
        $pictureBox.Image = [System.Drawing.Image]::Fromfile($file.fullname)
	
	$form.bringtofront()
	$form.refresh()
        Start-Sleep -Seconds $wait  
	SetThreadExecutionState(2) | out-null
}
While ($true)

