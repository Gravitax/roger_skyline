#!/bin/sh
# Ne pas oublier de passer la VM en bridged co

# echo "\n--- MAKE maboye sudo ---\n"
# echo "\n--- NEED USER PASSWORD ---\n"
# adduser maboye
# adduser maboye sudo

# echo "\n--- MAKING IP PARAMS ---\n"
# # reglage du netmask 30 et connection ssh static
# /etc/network/interfaces

# iface ens33 inet static
# 	address 10.13.42.101
# 	netmask 255.255.255.252
# 	gateway 10.13.254.254" > /etc/network/interfaces

# modifier le /etc/resolv.conf avec 8.8.8.8 pour pouvoir update

# echo "\n--- MAKING KEY PARAMS ---\n"
# definir /etc/ssh/sshd_config /home/maboye/.ssh/authorized_keys
# connection ssh:
# ssh -p 42 maboye@10.13.42.101
# generation de la clef sur MAC
# ssh-keygen
# copier la clef sur debian avec scp
# changer /etc/ssh/sshd_config

# # COPIER SCRIPTS !!!
# depuis le MAC scp -r -P 42 /Users/maboye/MAB  maboye@10.11.42.101:/home/maboye/.

cat /etc/ssh/sshd_config | sed 's/PermitRootLogin yes/PermitRootLogin no/g' | \
sed 's/PasswordAuthentication yes/PasswordAuthentication no/g' \
> /etc/ssh/sshd_config2 && mv /etc/ssh/sshd_config2 /etc/ssh/sshd_config

echo "\n--- UPDATING ---\n"
cp -r /home/maboye/scripts /root/.
sh /root/scripts/update.sh
apt-get install -y fail2ban
apt-get install -y portsentry
apt-get install -y mailutils
sh /root/scripts/firewall.sh
apt-get install -y iptables-persistent

echo "\n--- PORTSENTRY CONFIG ---\n"
echo 'TCP_MODE="atcp"
UDP_MODE="audp"' > /etc/default/portsentry
cat /etc/portsentry/portsentry.conf | sed 's/BLOCK_UDP="0"/BLOCK_UDP="1"/g' | \
sed 's/BLOCK_TCP="0"/BLOCK_TCP="1"/g' \
> /etc/portsentry/tmp && mv /etc/portsentry/tmp /etc/portsentry/portsentry.conf

echo "\n--- MAKING CRON CONFIG ---\n"
echo "SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# m h dom mon dow user  command
17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly
25 6    * * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6    * * 7   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6    1 * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
0  4    * * 0   root    sh /root/scripts/update.sh
0 0     * * *   root    sh /root/scripts/check_cron.sh
@reboot         root    sh /root/scripts/update.sh
#" > /etc/crontab

echo "\n--- INSTALLING APACHE ---\n"
sh /root/scripts/apache2.sh

# echo "\n--- END - REBOOT ---\n"
# reboot
