#!/usr/bin/env bash

#############################################################
# Bash tool to remove previously created Laravel site       #
#                                                           #
#############################################################

# This stops the script if any error occurrs
set -e
set -u

# Disable site function
disable() {
                # Find conf file for site
                echo -e "\e[0;31m Checking for config file to be removed ... \e[0m"
                echo " "
                echo -e "\033[0;37mConfig file to be removed \033[0m \033[0;36m $fRemove \033[0m"
                echo " "
                sleep 4

                echo -e "\e[0;31m Removing site config file ... \e[0m"
                # Remove file from /etc/apache2/sites-available
                sudo rm -rf "$fRemove"
                sleep 5
                echo  " "
                echo -e "\e[0;31m Removing site entry from /etc/hosts ... \e[0m"
                sudo sed -i.old "/^127.0.0.1\s*$1.local/d" /etc/hosts 
                sleep 4 
                echo " "
                echo -e "\033[0;34m Moving /etc/hosts.old to /tmp folder .. \033[0m"
                sudo mv /etc/hosts.old /tmp
                sleep 4
                echo " "
                echo -e "\e[0;31m A backup copy of the /etc/hosts file has been made! \e[0m"
                echo -e "\e[0;31m called /etc/hosts.old \e[0m"
                echo " "
                echo -e "\e[0;31m Restarting Apache ... \e[0m"
                sudo systemctl restart apache2 || echo -e "\e[0;31m Apache didn't restart please do so manually! \e[0m"
                sleep 5
}

# Get the name of the site to remove
echo -e "\e[0;34m Enter name of laravel folder in /var/www/html to remove \e[0m"
read -r site
fRemove=$(grep -ERl "$site".local /etc/apache2/sites-enabled/)

echo " "
echo -e "\033[0;37m Site folder to remove \033[0m \033[0;36m $site \033[0m"

# Check if that folder exists
# in the /var/www/html folder
if [[ -n "$site" ]]
then
        if [[ -d /var/www/html/"$site" ]]
        then
                echo -e "\e[0;34m Making a backup of the site folder in the \e[0m\e[0;31m/tmp folder\e[0m \e[0;34m ... \e[0m"
                # Preserve folder attributes when copying
                sudo cp -R --preserve /var/www/html/"$site" /tmp/"$site"
                sleep 5
                echo " "
                echo -e "\033[0;31m Removing site folder from /var/www/html ... \033[0m \033[0;36m $site \033[0m"
                sudo rm -rf /var/www/html/"$site"
                sleep 5
                echo  " "
                echo -e "\e[0;34m Disabling the site in Apache ... \e[0m"
                
                # sudo a2dissite "$site"
                if [[ ! $(sudo a2dissite "${fRemove##*/}") ]]
                then
                        echo -e "\e[0;31m That site configuration file doesn't exist! \e[0m"
                        echo " "
                        echo -e "\e[0;31m Please enter the correct name for the config file ... \e[0m"
                        read -r newconf
                        if [[ ! -n "$newconf" ]]
                        then
                                echo -e "\e[0;31m Program with exit as no config file name was entered \e[0m"
                                echo -e "\e[0;34m Restoring site files ... \e[0m"
                                sudo cp -R --preserve /tmp/"$site" /var/www/html/
                                sleep 5
                                exit 1
                        else
                                # Try disabling site again from Apache
                                if [[ $(sudo a2dissite "$newconf") ]]
                                then
                                        disable "$newconf" 
                                else
                                        echo -e "\e[0;31m Exiting script, site config not found ... \e[0m"
                                        echo " "
                                        exit 1
                                fi

                        fi
                else
                        disable "$site"                        
                fi
        else
                echo -e "\033[0;31m The specified folder\033[0m\033[0;36m $site \033[0m\033[0;31m doesn't exist in the /var/www/html folder! \033[0m"
                exit 1
        fi
else
        echo -e "\e[0;31m No name was entered! \e[0m"
        exit 1
fi
