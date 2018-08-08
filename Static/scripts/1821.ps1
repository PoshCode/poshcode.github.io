function Set-Encoding{

<#
.Synopsis
  Takes a Script file or any other text file into memory 
  and Re-Encodes it in the format specified.
.Parameter FilePath
  The path to the file to be re-encoded.
.Parameter Unicode 
  Outputs the file in Unicode format.
.Parameter UTF7
  Outputs the file in UTF7 format.
.Parameter UTF8
  Outputs the file in UTF8 format.
.Parameter UTF32
  Outputs the file in UTF32 format.
.Parameter ASCII
  Outputs the file in ASCII format.
.Parameter BigEndianUnicode
  Outputs the file in BigEndianUnicode format.
.Parameter Default
  Uses the encoding of the system's current ANSI code page.
.Parameter OEM
  Uses the current original equipment manufacturer code page 
  identifier for the operating system.
.Example
  ls *.ps1 | Set-Encoding -ASCII
.Description
  Written to provide an easy method to perform easy batch 
  encoding, calls on the command Out-File with the -Encoding 
  parameter and the -Force switch. Primarily to fix UnknownError
  status received when trying to sign non-ascii format files with
  digital signatures. Don't use on your MP3's or other non-text
  files :)
#>

[CmdletBinding()]

PARAM(
[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
[ValidateScript({ 
      if((resolve-path $_).Provider.Name -ne "FileSystem") {
         throw "Specified Path is not in the FileSystem: '$_'" 
      }
      return $true
   })]
[Alias("Fullname","Path")]
[string]$FilePath,
[switch]$Unicode,
[switch]$UTF7,
[switch]$UTF8,
[switch]$UTF32,
[switch]$ASCII,
[switch]$BigEndianUnicode,
[switch]$Default,
[switch]$OEM
)


BEGIN{
    $Encoding = ""
    switch(
        $Unicode,
        $UTF7,
        $UTF8,
        $UTF32,
        $ASCII, 
        $BigEndianUnicode,
        $Default, 
        $OEM
    ){
        $Unicode{$Encoding = "Unicode"}
        $UTF7{$Encoding = "UTF7"}
        $UTF8{$Encoding = "UTF8"}
        $UTF32{$Encoding = "UTF32"}
        $ASCII{$Encoding = "ASCII"} 
        $BigEndianUnicode{$Encoding = "BigEndianUnicode"}
        $Default{$Encoding = "Default"}
        $OEM{$Encoding = "OEM"}
    }

}

PROCESS{
    (Get-Content $FilePath) | Out-File -FilePath $FilePath -Encoding $Encoding -Force
}

}

