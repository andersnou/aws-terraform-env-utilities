#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
chkconfig httpd on
cd /var/www/html
PRIVATE_IP=`ifconfig eth0 | awk '/inet / {print $2}'`
echo "<body><h1>$PRIVATE_IP</h1></body>" > index.html
