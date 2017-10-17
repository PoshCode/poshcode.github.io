#for example, I wanna check ntdll.dll version
&{(gcm -c Application ntdll.dll).FileVersionInfo | fl *;cmd /c pause;cls}
