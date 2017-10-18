$plink = plink -ssh Administrator@$ILOIP -pw $PSWD -auto_store_key_in_cache "set /map1/oemhp_vm1/cddr1 oemhp_image=http://IPADDRESS/ISO.iso"
$plink = plink -ssh Administrator@$ILOIP -pw $PSWD -auto_store_key_in_cache "set /map1/oemhp_vm1/cddr1 oemhp_boot=connect"
$plink = plink -ssh Administrator@$ILOIP -pw $PSWD -auto_store_key_in_cache "set /map1/oemhp_vm1/cddr1 oemhp_boot=once"


