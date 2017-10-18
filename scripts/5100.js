(function() {
  var key = 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\',
      i, j, res;
      
  with (new ActiveXObject('WScript.Shell')) {
    res = {
      'ProductName' : RegRead(key + 'ProductName'),
      'ProductId'   : RegRead(key + 'ProductId'),
      'InstallDate' : (function(){
                        with (new Date(1970, 0, 1)) {
                          return new Date(
                            setSeconds(getSeconds() + RegRead(key + 'InstallDate'))
                          ).toLocaleDateString();
                        }
                      }()),
      'Owner'       : RegRead(key + 'RegisteredOwner'),
      'ProductKey'  : (function(){
                        var map = ('BCDFGHJKMPQRTVWXY2346789').split(''),
                            raw = RegRead(key + 'DigitalProductId').toArray().slice(52, 67),
                            a, b, res = [];
                        
                        for (a = 24; a >= 0; a--) {
                          var c = 0;
                          for (b = 14; b >= 0; b--) {
                            c = (c * 256) ^ raw[b];
                            raw[b] = Math.floor(c / 24);
                            c %= 24;
                          }
                          res = map[c] + res;
                          
                          if ((a % 5) === 0 && a !== 0) res = '-' + res;
                        }
                        return res;
                      }())
    };
  }
  
  for (i in res) {
    j = i;
    while (j.length != 12) j += ' ';
    WScript.echo(j + ': ' + res[i]);
  }
}());
