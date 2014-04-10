#!/bin/bash

#This script serves as a wrapper for the MyFLcontainer
#It starts necessary services, such as MySQL, prior to
#executing the main analysis program MyFLq.py

#Services
/usr/bin/supervisord
#/usr/sbin/mysqld &

#Setup MySQL for MyFLq
sleep 5 #mysqld needs some time to start up (maybe less than 5 seconds is also ok)
mysql <<EOF
GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY 'passall' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
#yes '' | python3 /myflq/MyFLdb.py --install root
python3 /myflq/MyFLdb.py --install admin -p 'passall'

#Start wrapper py
python3 /myflq/myflq_wrapper.py $@ #passes any arguments that come from run contqiner

#For debug
#echo $1 > /tmp/testargs
#echo $@
bash