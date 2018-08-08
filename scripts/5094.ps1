#replace [host_name] for something like ya.ru
tracert [host_name] | % {if(($ip=([Regex]"(\d+\.){3}\d+").Match($_).Value) -ne ''){$ip}}
