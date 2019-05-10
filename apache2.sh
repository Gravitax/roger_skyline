# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    apache2.sh                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: maboye <maboye@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2019/01/11 08:31:20 by maboye            #+#    #+#              #
#    Updated: 2019/01/20 16:19:18 by maboye           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/sh

echo "\n## DLL APACHE TOOLS ##\n"
apt-get install -y apache2
apt-get install -y build-essential
cp /etc/apache2/apache2.conf /home/maboye/.

cat /etc/apache2/apache2.conf | \
sed 's/denied/granted/1' > /etc/apache2/temp.conf && mv /etc/apache2/temp.conf /etc/apache2/apache2.conf

systemctl reload apache2
service apache2 restart

echo "\n## SSL PART ##\n"
mkdir /home/maboye/ssl_files
cd /home/maboye/ssl_files
openssl genrsa -des3 -out server.key 1024
openssl req -new -key server.key -out server.csr

cp server.key server.key.org
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

echo '<VirtualHost *:80>
	ServerName maboye
	DocumentRoot "/var/www/html"
	<directory /var/www/html>
		Options -Indexes +FollowSymLinks +MultiViews
		AllowOverride All
		Require all granted
	</Directory>
</VirtualHost>

<virtualhost *:443>
  ServerName maboye
  DocumentRoot "/var/www/html"
  # Activation du mode SSL
  SSLEngine On
  SSLOptions +FakeBasicAuth +ExportCertData +StrictRequire

  SSLCertificateFile "/home/maboye/ssl_files/server.crt"
  SSLCertificateKeyFile "/home/maboye/ssl_files/server.key"

  <directory /var/www/html>
    Options -Indexes +FollowSymLinks +MultiViews
    AllowOverride All
    Require all granted
  </Directory>
</virtualhost>' > /etc/apache2/sites-enabled/000-default.conf

rm -rf /var/www/html
cp -r /home/maboye/scripts/html /var/www/html

sudo a2enmod ssl
service apache2 restart
