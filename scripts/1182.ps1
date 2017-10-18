#########################################################
# Prevent-Screensaver
#########################################################
# This script "presses" a keyboard key every minute
# for specified number of minutes which makes
# Windows "think" you are at your desktop
# so the screensaver does not start and the desktop
# does not get locked. 
#########################################################
# Usage:
# & c:\filepath\Prevent-Screensaver.ps1 -Minutes 120
# Makes the script press "." for 120 minutes.
# Start notepad or another app and put focus there
# to see the dots appear and prevent beeping
########################################################
# (c) Dmitry Sotnikov
# http://dmitrysotnikov.wordpress.com
########################################################

param($minutes = 60)

$myshell = New-Object -com "Wscript.Shell"

for ($i = 0; $i -lt $minutes; $i++) {
  Start-Sleep -Seconds 60
  $myshell.sendkeys(".")
}
