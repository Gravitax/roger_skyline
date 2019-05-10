# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    check_crontab.sh                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: maboye <maboye@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2019/01/11 06:09:51 by maboye            #+#    #+#              #
#    Updated: 2019/01/11 06:40:49 by maboye           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash

if [ -e /var/log/crontab_checksum ]
then
	md5sum /etc/crontab > /tmp/crontab_check
	diff -q /tmp/crontab_check /var/log/crontab_checksum
	if [ $? -ne 0 ]
	then
		echo "/etc/crontab has been changed!" | mail -s crontab root@localhost
		md5sum /etc/crontab >> /var/log/crontab_checksum
	fi
else
	md5sum /etc/crontab > /var/log/crontab_checksum
fi
