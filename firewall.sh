# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    firewall.sh                                        :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: maboye <maboye@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2019/01/11 03:56:13 by maboye            #+#    #+#              #
#    Updated: 2019/01/21 11:27:06 by maboye           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/sh

# RESET
iptables -F
iptables -X

# ALL DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# KEEP ESTABLISHED CONNECTION
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# ACCEPT loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

## PORT
# nmap -v ip_de_la_machine -> auto port scan

# SSH = 42
iptables -A INPUT -p tcp --dport 42 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 42 -j ACCEPT

# DNS = 53
# HTTP = 80
# HTTPS = 443

# INPUT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
# OUTPUT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Allow ping
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

### DOS ATTACKS ###

# Stop smurf attacks
iptables -A INPUT -p icmp -m icmp --icmp-type address-mask-request -j DROP
iptables -A INPUT -p icmp -m icmp --icmp-type timestamp-request -j DROP
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -m limit --limit 1/second -j ACCEPT

# Drop all invalid packets
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j DROP

# Drop excessive RST packets
iptables -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit \
2/second --limit-burst 2 -j ACCEPT

# Drop all scans XMAS and NULL.
iptables -A INPUT -p tcp --tcp-flags FIN,URG,PSH FIN,URG,PSH -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

# fLOOD ou déni de service
iptables -A FORWARD -p tcp --syn -m limit --limit 1/second -j ACCEPT
iptables -A FORWARD -p udp -m limit --limit 1/second -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type echo-request -m limit --limit 1/second -j ACCEPT
