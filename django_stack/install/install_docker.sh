#!/bin/bash

# Make log folder
where_log=/var/log/docker_installation_log/

# Clear log folder
rm -rf $where_log
mkdir -p $where_log

# This script need to run in bash
if readlink /proc/$$/exe | grep -q "dash"; then
	echo 'This installer needs to be run with "bash", not "sh".'
	exit
fi

# Detect environments where $PATH does not include the sbin directories
if ! grep -q sbin <<< "$PATH"; then
	echo '$PATH does not include sbin. Try using "su -" instead of "su".'
	exit
fi

# Should running with superuser privileges
if [[ "$EUID" -ne 0 ]]; then
	echo "This installer needs to be run with superuser privileges."
	exit
fi

# Check the internet connection
if ping -c 1 -q google.com &> /dev/null; then
  echo -e "Checking the internet connection... \e[32m[OK]\e[0m"
else
  echo -e "Checking the internet connection... \e[31m[FAILED]\e[0m"
  exit
fi

# Remove crash
yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine -y 1>/dev/null 2>>$where_log/error.log
echo -e "Removing all old softwares... \e[32m[REMOVED]\e[0m"

# Install packages
yum install -y yum-utils 1>/dev/null 2>>$where_log/error.log
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 1>/dev/null 2>>$where_log/error.log
yum install docker-ce docker-ce-cli containerd.io -y 1>/dev/null 2>>$where_log/error.log

#install docker-compose 
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose 1>/dev/null 2>>$where_log/error.log

# Set execute permission on docker-compose
chmod +x /usr/local/bin/docker-compose 1>/dev/null 2>>$where_log/error.log
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose 1>/dev/null 2>>$where_log/error.log

systemctl start docker 1>/dev/null 2>>$where_log/error.log
systemctl enable docker.service 1>/dev/null 2>>$where_log/error.log
systemctl enable containerd.service 1>/dev/null 2>>$where_log/error.log

#install docker machine
base=https://github.com/docker/machine/releases/download/v0.16.0 \
  && curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine \
  && mv /tmp/docker-machine /usr/local/bin/docker-machine \
  && chmod +x /usr/local/bin/docker-machine

# Test all packages was installed yet
if rpm -q "docker-ce" && rpm -q "docker-ce-cli" && rpm -q "containerd.io" &> /dev/null;then
  echo -e "Installation status is...\e[32m[OK]\e[0m"
else
  echo -e "Installation status is...\e[31m[FAILED]\e[0m"
  exit
fi

# Server is running yet
check_docker=$(systemctl is-active docker)
if [ "$check_docker" = "active" ];then
  echo -e "Service docker status is...\e[32m[OK]\e[0m"
else
  echo -e "Service docker status is...\e[31m[FAILED]\e[0m"
  exit
fi

usermod -aG docker $USER
#read -p "Do you want to sign out to take effect? (y/n)" $answer
#if [ $answer = "y"] then
#  echo -e "$USER is signing out to take effect...\e[32m[OK]\e[0m"
#  exec su -l $USER
#else
#  echo -e "Keep this session"
#  exit
#fi

#chown "$USER":"$USER" /home/"$USER"/.docker -R
#chmod g+rwx "$HOME/.docker" -R
