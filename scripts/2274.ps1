function Set-FileWriteable {
#.Example
# $s = New-PSSession $ComputerName
# C:\PS>$files = Invoke-Command $s { ls }
# .... 
# C:\PS>Set-FileWriteable $files
#
param(
   [Parameter(Mandatory=$true,ValueFromPipeline=$true)]   
   $File
,
   [switch]$Passthru
)
process {
   foreach($path in @($file)) {
      write-verbose "'$path' is on '$($path.PSComputerName)'"
      if($path.PSComputerName) {
         Invoke-Command $path.PSComputerName {
            param([string[]]$path,[switch]$passthru)
            $files = Get-Item $path
            foreach($f in $files) {
               if($f.Attributes -band [IO.FileAttributes]"ReadOnly") {
                  $f.Attributes = $f.Attributes -bxor [IO.FileAttributes]"ReadOnly"
               }
            }
            write-output $files
         } -Argument $path | Where { $Passthru }
      } else {
         $files = Get-Item $path
         foreach($f in $files) {
            if($f.Attributes -band [IO.FileAttributes]"ReadOnly") {
               $f.Attributes = $f.Attributes -bxor [IO.FileAttributes]"ReadOnly"
            }
         }
         if($Passthru) { write-output $files }
      }
   }
}
}
