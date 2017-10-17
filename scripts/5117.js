(function() {
  var fso = new ActiveXObject('Scripting.FileSystemObject'),
      wsh = new ActiveXObject('WScript.Shell'),
      lst = function(e) {
        return wsh.ExpandEnvironmentStrings(e).split(';');
      },
      dir = lst('%PATH%'),
      ext = lst('%PATHEXT%;.DLL'),
      itm, i, j;
  
  try {
    for (i in dir) {
      for (j in ext) {
        itm = dir[i] + '\\' + WScript.Arguments.Unnamed(0) + ext[j].toLowerCase();
        if (fso.FileExists(itm)) WScript.echo(itm);
      }
    }
  }
  catch (e) { WScript.echo(e.name + ': ' + e.message + '.'); }
}());
