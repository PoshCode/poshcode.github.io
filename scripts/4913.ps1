Notes
=====
- download the script related files:<br>
   http://www3.bell.net/brearley/public/test-apps.ps1<br>
   http://www3.bell.net/brearley/public/test-apps.bat<br>
   http://www3.bell.net/brearley/public/powershell-exec-policy.reg<br>
- download wasp.dll from: http://wasp.codeplex.com/releases/view/22118<br>
- put wasp.dll in the same directory as the .ps1 file<br>
- you may have to unblock downloaded files<br>
- from windows explorer, right click on each file, select properties, click the Unblock button<br>
- if you are deploying this script as part of a PC image, it is best to turn on<br>
  powershell scripts in the registry via the supplied .reg file<br>
- if you are using the default windows user account control setting, then you will need to
  open the powershell window by right clicking and selecting the Run as Administrator option<br>
- if the script does not have administrator privileges, some of the tests will fail, the error
  messages will flag the administrator privilege issue<br>
- if you have changed the user account control setting to be more permissive, there is a .bat
  file to run the tests from windows explorer<br>
- if you uncomment line 34 of the .bat file, it will also update the registry entry needed to
  enable powershell scripts<br>
- for more details and options, in a powershell window, type: ./test-apps.ps1 -h<br>


