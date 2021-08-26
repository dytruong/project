#!/bin/bash
sudo yum update -y
sudo yum install -y python3
sudo yum groupinstall -y "Development Tools" && sudo yum install gcc openssl-devel bzip2-devel libffi-devel -y
sudo alternatives --install /usr/bin/python python /usr/bin/python2 50
sudo alternatives --install /usr/bin/python python /usr/bin/python3.6 60
sudo alternatives --config python
#fix yum
#sudo sed -i "s/bin\/python/\bin\/python2\.7/g" /usr/bin/yum /usr/libexec/urlgrabber-ext-down /usr/bin/yum-config-manager 