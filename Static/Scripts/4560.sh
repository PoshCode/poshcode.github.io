#!/bin/bash

num="\033[1;36m"
end="\033[0m"

read -p "Enter email without '@gmail.com': " email
read -p "Enter password of email: " pass

atom=`wget -qO - https://$email:$pass@mail.google.com/mail/feed/atom \
   --secure-protocol=TLSv1 -T 3 -t 1 --no-check-certificat | grep \
   fullcount | sed -e 's/<fullcount>\(.*\)<\/fullcount>/\1/'`

echo -e 'You have '$num$atom$end' new letter(s)'
