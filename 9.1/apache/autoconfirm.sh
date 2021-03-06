#!/bin/bash
groupadd -g 1501 mysql
useradd -m -u 1501 -g mysql -m -s /bin/false -d /var/lib/mysql mysql
apt-get update -y;
cd /usr/src/;
wget http://dev.mysql.com/get/mysql-apt-config_0.8.0-1_all.deb;
apt-get install -y lsb-release;
expect -c '
   set timeout 60;
   spawn dpkg -i mysql-apt-config_0.8.0-1_all.deb;
   expect "configure?";
   sleep 1;
   send "1\n";
   expect "receive?";
   sleep 1;
   send "1\n";
   expect "configure?";
   sleep 1;
   send "2\n";
   expect "utilities";
   sleep 1;
   send "1\n";
   expect "configure?";
   sleep 1;
   send "4\n";
   expect "OK";
   sleep 1;
   set timeout 600;
   spawn apt-get update -y;
   expect "Reading package lists... Done";
   sleep 1;
   spawn apt-get install -y mysql-server;
   set timeout 600;
   expect "Enter root password:";
   sleep 1;
   send "ehomevn\n";
   expect "enter root password:";
   sleep 1;
   send "ehomevn\n";
   expect "Processing triggers";
   sleep 2;
   interact;
';
