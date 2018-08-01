(function($) {
  var std, res, i;
  
  String.prototype.getLastValue = function() {
    var tmp = this.split("\\");
    return tmp[tmp.length - 1].replace(/\s+$/ig, '').toUpperCase();
  }
  
  with (new ActiveXObject('WScript.Shell')) {
    std = Exec("cmd /q /k echo off");
    std.StdIn.WriteLine("reg query \
      \"HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\ProfileList\" \
      /s | findstr /i /c:\"S-\" /c:\"ProfileImagePath\" & exit");
    res = std.StdOut.ReadAll().split('\n');
    
    for (i = 0; i < res.length; i++) {
      if (res[i].getLastValue() === $.toUpperCase())
        WScript.echo(res[i-1].getLastValue());
    } //for
  } //with
})('networkservice');
