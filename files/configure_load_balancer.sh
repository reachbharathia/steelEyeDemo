#!/bin/bash

echo "Get Nginx Status.."

status=$(service nginx status | grep "Active" | awk '{print substr($2, 1, length($2)-1)}')
if [ -z "$status" ]; then
        echo "Nginx Not installed.. So installing.. "
        echo "Download the ngx RPM.."
        wget https://nginx.org/packages/rhel/7/x86_64/RPMS/nginx-1.18.0-1.el7.ngx.x86_64.rpm
        echo "Installing nginx.."
        yum localinstall nginx-1.18.0-1.el7.ngx.x86_64.rpm -y
        systemctl start nginx
        echo "Print nginx status"
        systemctl status nginx

else
    echo "Nginx Already installed , So skipping the installation..  "
    systemctl status nginx
fi
sleep 30
echo "Configure Load Balancer.."

cd /etc/nginx/conf.d
echo "Nginx Path.."
pwd
ls
rm -rf *
serverIPOne=$1
serverIPTwo=$2

echo "Server One IP: $serverIPOne"
echo "Server TWO IP: $serverIPTwo"


cat >/etc/nginx/conf.d/load-balancer.conf <<EOL
upstream backend  {
  server ${serverIPOne}:8484;
  server ${serverIPTwo}:8484;

}
 server {
  location / {
    proxy_pass  http://backend;
  }
}
EOL

echo "Load Balancer Setup Completed.. Restating Nginx .."
echo "Printing Load Balancer Configuration file for refrence.."
cat /etc/nginx/conf.d/load-balancer.conf 
systemctl restart nginx


