(function() {
  var i, raw = 0,
      arr = (new ActiveXObject('WScript.Shell')).RegRead(
        'HKLM\\SYSTEM\\CurrentControlSet\\Control\\Windows\\ShutdownTime'
      ).toArray();
  for (i = arr.length; i--;) raw = raw * 0x100 + arr[i];
  WScript.echo(new Date((raw / 10000) + new Date(1601, 0, 1).getTime()));
}());
