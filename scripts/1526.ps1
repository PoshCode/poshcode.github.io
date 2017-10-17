cls

$ws  =  New-WebServiceProxy -Uri "http://192.168.1.1/sdk/vimService?wsdl" -Namespace "vimService1" ;

$ws.Url = "http://192.168.1.1/sdk/vimService";
$ws.UserAgent = "VMware VI Client/4.0.0";
$ws.CookieContainer = New-Object system.net.CookieContainer;

$mor_ret = new-object vimService1.ManagedObjectReference;

$mor_si = new-object vimService1.ManagedObjectReference;
$mor_si.type = "ServiceInstance";
$mor_si.Value = "ServiceInstance";

$mor_sm = new-object vimService1.ManagedObjectReference;
$mor_sm.type = "SessionManager";
$mor_sm.Value = "ha-sessionmgr";

$mor_hs = new-object vimService1.ManagedObjectReference;
$mor_hs.type = "HostSystem";
$mor_hs.Value = "ha-host";

$us = $ws.Login($mor_sm,"root","root", "en");

write-Host $ws.CurrentTime($mor_si);

#$mor_ret = $ws.RebootHost_Task($mor_hs, $true);

$ws.Logout($mor_sm);
