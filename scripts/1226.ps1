$devEnvArgs = '"' + "$pwd"+"\Installer\myInstaller.sln" + '"';
$devSwitches = '"' + "/rebuild Release 2>&1" + '"';
$output = &$vsExe $devEnvArgs $devSwitches;

