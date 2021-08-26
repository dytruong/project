#!/bin/bash
wget "https://www.sqlite.org/2021/sqlite-autoconf-3360000.tar.gz"
tar zxvf sqlite-autoconf-3360000.tar.gz
cd sqlite-autoconf-3360000/
./configure
sudo make && sudo make install
mv /usr/bin/sqlite3 /usr/bin/sqlite3.old
sudo ln -s /usr/local/bin/sqlite3 /usr/local/sqlite3
echo "export LD_LIBRARY_PATH=/usr/local/lib" >> ~/.bashrc
source ~/.bashrc
#clear trash
sudo rm -rf sqlite-autoconf-3360000.tar.gz sqlite-autoconf-3360000