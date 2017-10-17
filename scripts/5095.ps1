#replace [host_name] for something like ya.ru
&{tracert [host_name];[void]$host.UI.RawUI.ReadKey('NoEcho, IncludeKeyDown');cls}
