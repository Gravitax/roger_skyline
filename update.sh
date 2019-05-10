#!/bin/sh

echo "UPDATE : " > /var/log/update_script.log

apt-get update -y >> /var/log/update_script.log

echo "UPGRADE : " >> /var/log/update_script.log

apt-get upgrade -y >> /var/log/update_script.log

echo "DIST-UPGRADE : " >> /var/log/update_script.log

apt-get dist-upgrade -y >> /var/log/update_script.log
