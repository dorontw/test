#!/bin/bash

zab_db_host=localhost
zab_db_name=zabbix
zab_db_pass=zabbix

mysql_pass=Cell_2016

zab_conf_bk_path=/root/
zab_mysql_dump_path=/root/

date_time=`date '+%m_%d_%Y__%H:%M:%S'`

zabbix_download_deb=http://repo.zabbix.com/zabbix/3.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.0-1+trusty_all.deb
zabbix_install_deb=${zabbix_download_deb##*/}  # */ cuts the string that comes after the last dilimiter - in our case its / , if it was a different one for example a comma, it would be ${zabbix_install_link##*.} 

function exit_status_function {
if [ $? -ne 0 ]
then
        echo -e "\n--Operation failed - exiting script\n"
        exit
else
		echo -e "\n--Operation successful"
fi
}

#Main

echo -e "backing up old zabbix conf file"
sudo cp /etc/zabbix/zabbix_server.conf $zab_conf_bk_path/zabbix_server_conf_bk_$date_time
exit_status_function

echo -e "Stopping zabbix server before SQL dump"
sudo service zabbix-server stop
exit_status_function

echo -e "\nPerforming SQL dump"
sudo mysqldump -uroot -p$mysql_pass zabbix > $zab_mysql_dump_path/zabbix_dump_$DATE_TIME.sql
exit_status_function

cp /etc/zabbix/zabbix_server.conf $zab_conf_bk_path/zabbix_server_conf_bk_$date_time
exit_status_function

echo -e "\ndownloading zabbix installation deb file"
wget $zabbix_download_deb

echo -e "\nunpacking zabbix installation deb file"
dpkg -i $zabbix_install_deb

apt-get update

echo -e "\nRemoving and purging old zabbix server"
sudo apt-get remove --purge zabbix-server-mysql -y
exit_status_function

echo -e "\nRemoving and purging old zabbix frontend"
sudo apt-get remove --purge zabbix-frontend-php -y 
exit_status_function

echo -e "\nRemoving and purging old zabbix agent"
sudo apt-get remove --purge zabbix-agent -y
exit_status_function

echo -e "\nInstalling new zabbix server"
sudo apt-get install zabbix-server-mysql -y
exit_status_function

echo -e "\nInstalling new zabbix frontend"
sudo apt-get install zabbix-frontend-php -y
exit_status_function

echo -e "\nInstalling new zabbix agent"
sudo apt-get install zabbix-agent -y
exit_status_function


#back up the current zabbix_server.conf file to our choosen backup path
cp /etc/zabbix/zabbix_server.conf $zab_conf_bk_path/zabbix_server_conf_bk_$date_time

#back up the current zabbix_server.conf file to our choosen backup path
cp /etc/zabbix/zabbix_server.conf $zab_conf_bk_path/zabbix_server_conf_bk_$date_time

#comment out any line that starts with DBHost=
sed -i -r '/^DBHost=/ s/^(.*)$/#\1/g' /etc/zabbix/zabbix_server.conf

#comment out any line that starts with DBName=
sed -i -r '/^DBName=/ s/^(.*)$/#\1/g' /etc/zabbix/zabbix_server.conf

#comment out any line that starts with DBPassword=
sed -i -r '/^DBPassword=/ s/^(.*)$/#\1/g' /etc/zabbix/zabbix_server.conf

#Adds the line DBHost=$zab_db_host  after a commented #DBPassword line
sed -i "/#DBHost=/a DBHost=$zab_db_host" /etc/zabbix/zabbix_server.conf

#Adds the line DBName=$zab_db_host  after a commented #DBPassword line
sed -i "/#DBName=/a DBName=$zab_db_name" /etc/zabbix/zabbix_server.conf

#Adds the line DBPassword=$zab_db_pass  after a commented #DBPassword line
sed -i "/#DBPassword=/a DBPassword=$zab_db_pass" /etc/zabbix/zabbix_server.conf ; sed -i "/# DBPassword=/a DBPassword=$zab_db_pass" /etc/zabbix/zabbix_server.conf


echo -e "\nRemoving old zabbix web frontend"
rm -rf /var/www/html/zabbix

echo -e "\nCopy new zabbix web frontend"
exit_status_function
cp -r /usr/share/zabbix/ /var/www/html/zabbix
exit_status_function

service zabbix-server restart
exit_status_function
service zabbix-agent restart
exit_status_function



- need to check if a line that that starts #DBPassword exists or not
########3

#check
cat /etc/zabbix/zabbix_server.conf | grep ^DBPassword=
if [ $? = 0 ]
then
	#comment the line
	sed -i -r '/^DBPassword=/ s/^(.*)$/#\1/g' /etc/zabbix/zabbix_server.conf
	#insert the new line below the commented line
	sed -i '/#DBPassword=/a DBPassword=zabbix' /etc/zabbix/zabbix_server.conf
else
	#add it to the bottom of the conf file
	echo DBPassword=zabbix >> /etc/zabbix/zabbix_server.conf
fi
	
##############3	
	
	#add string to end of string that starts with DBPassword
    sed -i '/^#DBPassword/s/.*/& cowpower/' /etc/zabbix/zabbix_server.conf 
	
I want to add a date to it
DATE_TIME=`date '+%m_%d_%Y__%H:%M:%S'`
sed -i '/^#DBPassword/s/.*/& #commented at '$DATE_TIME'/' /etc/zabbix/zabbix_server.conf 

echo -e "\nRemoving old zabbix web frontend"
rm -rf /var/www/html/zabbix

echo -e "\nInstall old zabbix web frontend"
cp -r /usr/share/zabbix/ /var/www/html/zabbix



