#!/bin/bash

if [ ! -d /var/log/base_install/userdata_log ]; then
  sudo mkdir -m 777 -p /var/log/base_install/userdata_log
fi


exec > >(tee /var/log/base_install/userdata_log/pre_software_install.log|logger -t user-data -s 2>/dev/console) 2>&1

#switch to root user
echo `date '+%Y-%m-%d %H:%M:%S '` "Switch to root user"
sudo su
cd

#Install Code Deploy Agent
echo `date '+%Y-%m-%d %H:%M:%S '` "Region : $Region"
echo `date '+%Y-%m-%d %H:%M:%S '` "Install Code Deploy Agent"
aws s3 cp s3://aws-codedeploy-$Region/latest/install . --region $Region
chmod +x ./install
./install auto

#Install SSM
echo `date '+%Y-%m-%d %H:%M:%S '` "SSM Agent install"
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sleep 30

