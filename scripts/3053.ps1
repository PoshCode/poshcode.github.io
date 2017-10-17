<#
.Synopsis
Let's fill the logs of the US House and Senate servers with the message we don't want SOPA or E-Parasite!
.Description
Runs an while(1) loop that grabs a couple URI's from each branch's website and sleeps for 1 second between requests.
#>

# twitter tags
#occupyUSSenate
#occupyUSHouse
#sopa
#eparasite

while(1){
    try{
        (new-object net.webclient).downloadstring("http://www.house.gov/downWithSOPA") | Out-Null;
    } catch{}
    
    try{
        (new-object net.webclient).downloadstring("http://www.senate.gov/downWithE-Parasite") | out-n
    } catch{}
    
    sleep 1;
}
