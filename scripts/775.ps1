Set-Alias ISE Invoke-ISE  
function Invoke-ISE ()
<#
.SYNOPSIS
    start ISE from the PS-commandline
.DESCRIPTION
    start ISE provide files as parameters or per pipe-line
.NOTES
    Author : Bernd Kriszio - http://pauerschell.blogspot.com/
    Requires   : PowerShell V2 CTP3
.EXAMPLE   
    Invoke-ISE $foo.ps1
.EXAMPLE   
    Invoke-ISE foo.ps1 foobar.ps1
.EXAMPLE   
    Invoke-ISE 'foo.ps1' 'foobar.ps1'
.EXAMPLE   
    get-childitem f*.ps1 | Invoke-ISE
.EXAMPLE   
    Invoke-ISE (dir f*.ps1) 
.EXAMPLE   
    'foo.ps1' | Invoke-ISE
.EXAMPLE   
    Invoke-ISE
.LINK
    http://tfl09.blogspot.com/2009/01/parameter-attributes-in-powershell-v2.html
    http://blogs.microsoft.co.il/blogs/scriptfanatic/archive/2008/12/30/windows-powershell-integrated-scripting-environment-ise.aspx
#>
       
{
    param (     
        [Parameter(Position = 0, 
                    Mandatory=$false, 
                    ValueFromPipeline=$True, 
                    ValueFromRemainingArguments = $true)]
        [string[]]$file    
    )     
    begin {
        $path="$pshome\powershell_ise.exe"
        if ($file -eq $null){
            & $path
        }
    }  
    PROCESS {
            foreach($f in $file){
                # note the comment of Mark Schill
                # & $path (resolve-path $f)
                # http://blogs.microsoft.co.il/blogs/scriptfanatic/archive/2008/12/30/windows-powershell-integrated-scripting-environment-ise.aspx#comments
                & $path ( ([system.IO.FileInfo]$f).FullName)     
            }    
    }
}
