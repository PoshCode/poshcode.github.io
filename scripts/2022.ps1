
Function Create-Password {
        #How many characters in the password
        [int]$passwordlength = 14
        
        ##Make sure that number of characters below are not greater than $passwordlength!!
        
        #Minimum Upper Case characters in password
        [int]$min_upper = 3
        
        #Minimum Lower Case characters in password
        [int]$min_lower = 3
        
        #Minimum Numerical characters in password
        [int]$min_number = 3
        
        #Minimum Symbol/Puncutation characters in password
        [int]$min_symbol = 3
        
        #Misc password characters in password
        [int]$min_misc = ($passwordlength - ($min_upper + $min_lower + $min_number + $min_symbol))
        
        #Characters for the password
        $upper = @("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
        $lower = @("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
        $number = @(1,2,3,4,5,6,7,8,9,0)
        $symbol = @("!","@","#","%","&","(",")","`"",".","<",">","+","=","-","_")
        $combine = $upper + $lower + $number + $symbol
        
        $password = @()
        
        #Start adding upper case into password
        1..$min_upper | % {$password += Get-Random $upper}
        #Add lower case into password            
        1..$min_lower | % {$password += Get-Random $lower} 
        #Add numbers into password
        1..$min_number | % {$password += Get-Random $number}
        
        #Add symbols into password
        1..$min_symbol | % {$password += Get-Random $symbol}    
        
        #Fill out the rest of the password length
        1..$min_misc | % {$password += Get-Random $combine}            
        
        #Randomize password
        Get-Random $password -count $passwordlength | % {[string]$randompassword += $_}
        Return $randompassword    
    }
#Generated Form Function
function GenerateForm {

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
#endregion

#Show popup if not running in -STA mode
If (((get-host).RunSpace).ApartmentState -ne "STA") {
    [System.Windows.Forms.MessageBox]::Show("You are not running Powershell in (Single Threaded Apartment) STA mode! Please restart powershell in STA mode (powershell.exe -STA)","Warning") | Out-Null
    Break
    }

#region Generated Form Objects
$form1 = New-Object System.Windows.Forms.Form
$textBox1 = New-Object System.Windows.Forms.TextBox
$lbl_summary = New-Object System.Windows.Forms.Label
$lbl_passwordlabel = New-Object System.Windows.Forms.Label
$btn_generate = New-Object System.Windows.Forms.Button
$chk_printreport = New-Object System.Windows.Forms.CheckBox
$lbl_bottomheader = New-Object System.Windows.Forms.Label
$lbl_topheader = New-Object System.Windows.Forms.Label
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.
$btn_generate_OnClick= {
    #Saving password to variable
    $password = Create-Password

    #Displaying password to screen
    $textBox1.Text = $password 
    Start-Sleep -Seconds 1

    If ($($chk_printreport.Checked) -eq $True) {
        #Define Printer - Uses Default printer
        
$code = @'
using System;
using System.Runtime.InteropServices;
using System.Drawing;
using System.Drawing.Imaging;
namespace ScreenShotDemo
{
  /// <summary>
  /// Provides functions to capture the entire screen, or a particular window, and save it to a file.
  /// </summary>
  public class ScreenCapture
  {
    /// <summary>
    /// Creates an Image object containing a screen shot of the entire desktop
    /// </summary>
    /// <returns></returns>
    public Image CaptureScreen()
    {
      return CaptureWindow( User32.GetForegroundWindow() );
    }
    /// <summary>
    /// Creates an Image object containing a screen shot of a specific window
    /// </summary>
    /// <param name="handle">The handle to the window. (In windows forms, this is obtained by the Handle property)</param>
    /// <returns></returns>
    public Image CaptureWindow(IntPtr handle)
    {
      // get te hDC of the target window
      IntPtr hdcSrc = User32.GetWindowDC(handle);
      // get the size
      User32.RECT windowRect = new User32.RECT();
      User32.GetWindowRect(handle,ref windowRect);
      int width = windowRect.right - windowRect.left;
      int height = windowRect.bottom - windowRect.top;
      // create a device context we can copy to
      IntPtr hdcDest = GDI32.CreateCompatibleDC(hdcSrc);
      // create a bitmap we can copy it to,
      // using GetDeviceCaps to get the width/height
      IntPtr hBitmap = GDI32.CreateCompatibleBitmap(hdcSrc,width,height);
      // select the bitmap object
      IntPtr hOld = GDI32.SelectObject(hdcDest,hBitmap);
      // bitblt over
      GDI32.BitBlt(hdcDest,0,0,width,height,hdcSrc,0,0,GDI32.SRCCOPY);
      // restore selection
      GDI32.SelectObject(hdcDest,hOld);
      // clean up
      GDI32.DeleteDC(hdcDest);
      User32.ReleaseDC(handle,hdcSrc);
      // get a .NET image object for it
      Image img = Image.FromHbitmap(hBitmap);
      // free up the Bitmap object
      GDI32.DeleteObject(hBitmap);
      return img;
    }
    /// <summary>
    /// Captures a screen shot of a specific window, and saves it to a file
    /// </summary>
    /// <param name="handle"></param>
    /// <param name="filename"></param>
    /// <param name="format"></param>
    public void CaptureWindowToFile(IntPtr handle, string filename, ImageFormat format)
    {
      Image img = CaptureWindow(handle);
      img.Save(filename,format);
    }
    /// <summary>
    /// Captures a screen shot of the entire desktop, and saves it to a file
    /// </summary>
    /// <param name="filename"></param>
    /// <param name="format"></param>
    public void CaptureScreenToFile(string filename, ImageFormat format)
    {
      Image img = CaptureScreen();
      img.Save(filename,format);
    }
   
    /// <summary>
    /// Helper class containing Gdi32 API functions
    /// </summary>
    private class GDI32
    {
      
      public const int SRCCOPY = 0x00CC0020; // BitBlt dwRop parameter
      [DllImport("gdi32.dll")]
      public static extern bool BitBlt(IntPtr hObject,int nXDest,int nYDest,
        int nWidth,int nHeight,IntPtr hObjectSource,
        int nXSrc,int nYSrc,int dwRop);
      [DllImport("gdi32.dll")]
      public static extern IntPtr CreateCompatibleBitmap(IntPtr hDC,int nWidth,
        int nHeight);
      [DllImport("gdi32.dll")]
      public static extern IntPtr CreateCompatibleDC(IntPtr hDC);
      [DllImport("gdi32.dll")]
      public static extern bool DeleteDC(IntPtr hDC);
      [DllImport("gdi32.dll")]
      public static extern bool DeleteObject(IntPtr hObject);
      [DllImport("gdi32.dll")]
      public static extern IntPtr SelectObject(IntPtr hDC,IntPtr hObject);
    }

    /// <summary>
    /// Helper class containing User32 API functions
    /// </summary>
    private class User32
    {
      [StructLayout(LayoutKind.Sequential)]
      public struct RECT
      {
        public int left;
        public int top;
        public int right;
        public int bottom;
      }
      [DllImport("user32.dll")]
      public static extern IntPtr GetDesktopWindow();
      [DllImport("user32.dll")]
      public static extern IntPtr GetWindowDC(IntPtr hWnd);
      [DllImport("user32.dll")]
      public static extern IntPtr ReleaseDC(IntPtr hWnd,IntPtr hDC);
      [DllImport("user32.dll")]
      public static extern IntPtr GetWindowRect(IntPtr hWnd,ref RECT rect);
      [DllImport("user32.dll")]
      public static extern IntPtr GetForegroundWindow();      
    }
  }
}
'@

add-type $code -ReferencedAssemblies 'System.Windows.Forms','System.Drawing'     
        
        #Print Form
		$form1.FormBorderStyle = 0
        $form1.Activate()
        $fph = New-Object ScreenShotDemo.ScreenCapture
        $img = $fph.CaptureScreen()
        $pd = New-Object System.Drawing.Printing.PrintDocument
        $pd.Add_PrintPage({$_.Graphics.DrawImage(([System.Drawing.Image]$img), 0, 0)})
        $pd.Print()            

        $form1.FormBorderStyle = 5
        }    
    #Pasting password to clipboard
    #This will only work if Powershell is running in Single Threaded Apartment (STA): powershell.exe -sta or run from ISE
    #You can check by running the following command: ((get-host).RunSpace).ApartmentState
    [Windows.Forms.Clipboard]::SetText($password)     

}

$handler_form1_Load= 
{
    $form1.TopMost = $True
    $form1.Activate()

}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
	$form1.WindowState = $InitialFormWindowState
}

#----------------------------------------------
#region Generated Form Code
$form1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,1,3,0)
$form1.BackColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$form1.Text = "Password Generator"
$form1.AllowDrop = $True
$form1.Name = "form1"
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 685
$System_Drawing_Size.Height = 496
$form1.ClientSize = $System_Drawing_Size
$form1.FormBorderStyle = 5
$form1.add_Load($handler_form1_Load)

$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 227
$System_Drawing_Size.Height = 19
$textBox1.Size = $System_Drawing_Size
$textBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$textBox1.ReadOnly = $True
$textBox1.BorderStyle = 0
$textBox1.Text = "NOTVALID1"
$textBox1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",12,1,3,0)
$textBox1.Name = "textBox1"
$textBox1.BackColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 304
$System_Drawing_Point.Y = 268
$textBox1.Location = $System_Drawing_Point
$textBox1.TabIndex = 7
$textBox1.add_TextChanged($handler_textBox1_TextChanged)

$form1.Controls.Add($textBox1)

$lbl_summary.TabIndex = 6
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 619
$System_Drawing_Size.Height = 156
$lbl_summary.Size = $System_Drawing_Size
$lbl_summary.Text = "Ensure your password contains at least 3 special characters, 3 numbers, 3 uppercase and 3 lowercase letters for a total of at least 14 characters long. You will be unable to change this password for the next 24 hours."
$lbl_summary.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",12,1,3,0)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 41
$System_Drawing_Point.Y = 85
$lbl_summary.Location = $System_Drawing_Point
$lbl_summary.DataBindings.DefaultDataSourceUpdateMode = 0
$lbl_summary.Name = "lbl_summary"

$form1.Controls.Add($lbl_summary)

$lbl_passwordlabel.TabIndex = 4
$lbl_passwordlabel.TextAlign = 64
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 111
$System_Drawing_Size.Height = 47
$lbl_passwordlabel.Size = $System_Drawing_Size
$lbl_passwordlabel.Text = "Password:"
$lbl_passwordlabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",12,1,3,0)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 184
$System_Drawing_Point.Y = 254
$lbl_passwordlabel.Location = $System_Drawing_Point
$lbl_passwordlabel.DataBindings.DefaultDataSourceUpdateMode = 0
$lbl_passwordlabel.Name = "lbl_passwordlabel"

$form1.Controls.Add($lbl_passwordlabel)

$btn_generate.TabIndex = 3
$btn_generate.Name = "btn_generate"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 104
$System_Drawing_Size.Height = 39
$btn_generate.Size = $System_Drawing_Size
$btn_generate.UseVisualStyleBackColor = $True

$btn_generate.Text = "Generate"
$btn_generate.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8.25,1,3,0)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 304
$System_Drawing_Point.Y = 364
$btn_generate.Location = $System_Drawing_Point
$btn_generate.DataBindings.DefaultDataSourceUpdateMode = 0
$btn_generate.add_Click($btn_generate_OnClick)

$form1.Controls.Add($btn_generate)


$chk_printreport.UseVisualStyleBackColor = $True
$chk_printreport.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9,1,3,0)
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 104
$System_Drawing_Size.Height = 24
$chk_printreport.Size = $System_Drawing_Size
$chk_printreport.TabIndex = 2
$chk_printreport.Text = "Print Report"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 304
$System_Drawing_Point.Y = 323
$chk_printreport.Location = $System_Drawing_Point
$chk_printreport.DataBindings.DefaultDataSourceUpdateMode = 0
$chk_printreport.Name = "chk_printreport"
$chk_printreport.checked = $True


$form1.Controls.Add($chk_printreport)

$lbl_bottomheader.TabIndex = 1
$lbl_bottomheader.ImageAlign = 512
$lbl_bottomheader.TextAlign = 32
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 662
$System_Drawing_Size.Height = 59
$lbl_bottomheader.Size = $System_Drawing_Size
$lbl_bottomheader.Text = "FOR OFFICIAL USE ONLY"
$lbl_bottomheader.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",20.25,1,3,0)
$lbl_bottomheader.ForeColor = [System.Drawing.Color]::FromKnownColor("Green")

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 11
$System_Drawing_Point.Y = 425
$lbl_bottomheader.Location = $System_Drawing_Point
$lbl_bottomheader.DataBindings.DefaultDataSourceUpdateMode = 0
$lbl_bottomheader.Name = "lbl_bottomheader"
$lbl_bottomheader.add_Click($handler_label2_Click)

$form1.Controls.Add($lbl_bottomheader)

$lbl_topheader.TabIndex = 0
$lbl_topheader.ImageAlign = 512
$lbl_topheader.TextAlign = 32
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 662
$System_Drawing_Size.Height = 59
$lbl_topheader.Size = $System_Drawing_Size
$lbl_topheader.Text = "FOR OFFICIAL USE ONLY"
$lbl_topheader.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",20.25,1,3,0)
$lbl_topheader.ForeColor = [System.Drawing.Color]::FromKnownColor("Green")

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 11
$System_Drawing_Point.Y = 6
$lbl_topheader.Location = $System_Drawing_Point
$lbl_topheader.DataBindings.DefaultDataSourceUpdateMode = 0
$lbl_topheader.Name = "lbl_topheader"
$lbl_topheader.add_Click($handler_label1_Click)

$form1.Controls.Add($lbl_topheader)

#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState
#Init the OnLoad event to correct the initial state of the form
$form1.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$form1.ShowDialog()| Out-Null
} #End Function

#Call the Function
GenerateForm

