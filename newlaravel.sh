#!/usr/bin/env bash

# This stops the script if any of the commands fails
set -e
set -u

###############################################################################
# Script to help setup a laravel site on Ubuntu Xenial Xepus                  #
# requires you pass in 1. name of site, example somesite.[a-z]{3}             #
# it will be install to /var/www/html, and the Virtualhost file will          #
# be setup in /etc/apache2/sites-available with the name of your choice,      #
# and activated with `sudo a2ensite /etc/apache2/somesite.conf`               #
# Apache will be restarted with `sudo systemctl restart apache2`              #
###############################################################################

# Get the name of the laravel site and the Virtualhost config file name
echo -e "\e[0;34m Enter laravel site name to create \e[0m"
read -r site

# check the name is on alphabets or not-empty
if [[ -n "$site" ]]
then
        if [[ "$site" =~ ^[a-zA-Z]+$ ]]
        then
                # convert site name to lower case letters
                site=$(echo "$site" | tr '[:upper:]' '[:lower:]')
                #echo "$site"

                # get the Virtualhost conf file name
                echo -e "\e[0;34m Enter the name of the apache virtualhost file to create \e[0m"
                read -r apconf

                if [[ -n "$apconf" ]]
                then
                        #echo "Entry not empty! $apconf.conf"
                        if [[ "$apconf" =~ ^[[:alnum:]][-[:alnum:]]{0,61}[[:alnum:]]$ ]]
                        then
                                # convert all letters to lower case
                                apconf=$(echo "$apconf" | tr '[:upper:]' '[:lower:]')
                                echo -e "\033[0;37m Name entered for config file \033[0m \033[0;36m $apconf \033[0m"
                                apconf="$apconf.conf"
                                echo -e "\e[0;37m Config file name:\e[0m \e[0;36m $apconf \e[0m"

                                # Delay the next command so user will see echo output
                                sleep 5
                                
                        else
                                echo -e "\e[0;31m Name can only contain alphanumeric! \e[0m"
                                exit 1
                        fi
                else
                        echo -e "\e[0;31m Nothing was entered, please enter a name! \e[0m"
                        exit 1
                fi
        else
                echo -e "\e[0;31m Only alphabets allowed! \e[0m"
                exit 1
        fi
else
        echo -e "\e[0;31m Nothing was entered at terminal! \e[0m"
        exit 1

fi
# Create laravel site
echo -e "\e[0;37m Change into '\e[0;36m /var/www/html \e[0m' directory \e[0m"
cd /var/www/html
echo ""
echo -e "\e[0;37m Checking if laravel is installed... \e[0m"
which laravel
sleep 5
echo -e "\e[0;37m It is so we create new application! \e[0m"
echo ""
echo -e "\e[0;37m Begin laravel site creation... \e[0m" 
laravel new "$site"
echo -e "\e[0;37m Finished laravel site creation... \e[0m"

echo ""
# Create site apache config file
echo -e "\e[0;37m Creaing $apconf in \e[0m \e[0;36m /etc/apache2/sites-available/ \e[0m"
sudo touch /etc/apache2/sites-available/"$apconf"
sleep 3
echo ""
# Write configuration into conf file
echo -e "\e[0;37m Writing to config file in \e[0m \e[0;36m/etc/apache2/sites-available/$apconf ...\e[0m"
sleep 5
echo ""
echo "<VirtualHost *:80>

        ServerName $site.local
        DocumentRoot /var/www/html/$site/public/
	    DirectoryIndex index.php

	    <Directory />
		    Options FollowSymLinks
		    AllowOverride None
	    </Directory>

        <Directory /var/www/html/$site>
	        AllowOverride All
		Require all granted
        </Directory>

        ErrorLog \${APACHE_LOG_DIR}/error.log
        LogLevel warn
        CustomLog \${APACHE_LOG_DIR}/access.log combined
    </VirtualHost>" | sudo tee /etc/apache2/sites-available/"$apconf"
echo ""
echo -e "\e[0;37m Finished writing config file\e[0m"

# Write name of laravel application in /etc/hosts
echo ""
echo -e "\e[0;37m Writing in \e[0m \e[0;36m /etc/hosts file ...\e[0m"
# Find a blank space and add the new entry
sudo sed -i "s/^[[:space:]]*$/127.0.0.1       $site.local\n/"  /etc/hosts
sleep 5
echo  -e "\e[0;37m Finished writing to \e[0m \e[0;36m /etc/hosts ...\e[0m"
echo ""

#Changing ownership on laravel file
echo -e "\e[0;37m Changing owner of laravel application file \e[0m"
sudo chown -R "$USER":www-data /var/www/html/"$site"
sleep 3
echo ""
echo -e "\e[0;31m Make the Laravel storage folder accessible with permission 775!\e[0m"
sudo chmod -R 775 "$site"/storage
sleep 5
echo " "
echo -e "\e[0;31m Please add yourself to the www-data (apache group) if not in that group already!\e[0m"
echo -e "\e[0;31m do that with the command \e[0m \e[0;36m 'sudo usermod -a -G www-data' $USER \e[0m"
echo ""
# Activate the config file in apache
echo -e "\e[0;34m Enabling site...\e[0m"
sudo a2ensite "$apconf"
sleep 5
echo ""
echo -e "\e[0;34m Restarting apache... \e[0m"
sudo systemctl restart apache2 || echo "apache wasn't restart please do so manually!"
sleep 5
echo ""
echo "Finished"
exit 0

