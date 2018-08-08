#####################################################################
# Test-FileLock.ps1
# Version 1.0
#
# test if file is locked by external program or not
#
# Vadims Podans (c) 2009
# http://www.sysadmins.lv/
#####################################################################

filter Test-FileLock {
    if ($args[0]) {$filepath = gi $(Resolve-Path $args[0]) -Force} else {$filepath = gi $_.fullname -Force}
    if ($filepath.psiscontainer) {return}
    $locked = $false
    trap {
        Set-Variable -name locked -value $true -scope 1
        continue
    }
    $inputStream = New-Object system.IO.StreamReader $filepath
    if ($inputStream) {$inputStream.Close()}
    @{$filepath = $locked}
}
