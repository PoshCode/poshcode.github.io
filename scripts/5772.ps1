[DateTime]::FromFileTime(
   [BitConverter]::ToInt64(
      (gp 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\LastFontSweep').LastSweepTime, 0
   )
)
