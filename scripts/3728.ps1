@echo off
 ::unequal symbols
 for %%i in ("!", "x") do if "%1" equ "%%~i" goto:error
 ::display help information args
 for %%i in ("-h", "/h", "-help", "/help") do (
   if "%1" equ "%%~i" goto:help
 )
 if "%1" equ "-?" goto:help
 if "%1" equ "/?" goto:help
 ::interactive mode
 if "%1" equ "" (
   if not defined run goto:interactive
   goto:error
 )
 ::parsing input data
 setlocal enabledelayedexpansion
  ::checking is arg hex or dec
  2>nul set /a "res=%1"
  if "%1" equ "%res%" goto:dec2hex
  ::patterns
  echo "%1" | findstr /r \x > nul
  set e1=%errorlevel%
  echo "%1" | findstr /r [0-9a-f] > nul
  set e2=%errorlevel%
  echo "%1" | findstr /r [g-wyz] > nul
  set e3=%errorlevel%
  ::parsing error codes
  if %e1% equ 0 if %e2% equ 0 if %e3% equ 1 set "k=%1"   & goto:hex2dec
  if %e1% equ 1 if %e2% equ 0 if %e3% equ 1 set "k=0x%1" & goto:hex2dec
  goto:error

  :dec2hex
  2>nul set /a "num=%1"
  set "map=0123456789ABCDEF"
  for /l %%i in (1, 1, 8) do (
    set /a "res=num & 15, num >>=4"
    for %%j in (!res!) do set "hex=!map:~%%j,1!!hex!"
  )
  for /f "tokens=* delims=0" %%i in ("!hex!") do set "hex=0x%%i"
  echo %1 = !hex! & goto:eof

  :hex2dec
  set "num=%k%"
  if "%num:~0,1%" equ "x" goto:error
  2>nul set /a "res=%k%"
  for /f "tokens=2,3" %%i in ('findstr "# " "%~dpnx0"') do set "num=!num:%%i=%%j!"
  if "%res%" neq "" (echo !num! = !res!) else goto:error
 endlocal
exit /b

:error
  if defined run echo =^>err & goto:eof
  echo Invalid data.
exit /b 1

:help
::Hex2dec v1.10 - converts hex to decimal and vice versa
::Copyright (C) 2012 Greg Zakharov
::forum.script-coding.com
::
::Usage: hex2dec [decimal | hexadecimal]
::
::Example 1:
::  C:\>hex2dec 0x017a
::  0x017A = 378
::
::Example 2:
::  C:\>hex2dec 13550
::  13550 = 0x34EE
::
::Example 3:
::  C:\>hex2dec 23f
::  0x23F = 575
for /f "tokens=* delims=:" %%i in ('findstr "^::" "%~dpnx0"') do echo.%%i
exit /b 0

rem :: Upper case chart ::
# a A
# b B
# c C
# d D
# e E
# f F
rem ::   End of chart   ::

:interactive
 ::interactive mode on
 echo Hex2dec v1.10 - converts hex to decimal and vice versa
 echo.
 setlocal
  ::marker - already launched
  set run=true
  :begin
  set /p "ask=>>> "
  cmd /c "%~dpnx0" %ask%
  if "%ask%" equ "clear" cls
  if "%ask%" equ "exit"  cls & goto:eof
  echo.
  goto:begin
 endlocal
exit /b
