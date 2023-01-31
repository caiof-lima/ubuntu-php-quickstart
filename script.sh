#!/bin/bash

# define functions

install_composer() {
    sudo curl -s https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/bin/composer    
}

install_xdebug() {
    sudo apt install "php${php_ver}-xdebug" -y
    touch /tmp/xdebug.log
    check=$(echo -e "xdebug.mode = debug\nxdebug.start_with_request = yes\nxdebug.client_port = 9003\nxdebug.client_host = \"127.0.0.1\"\nxdebug.log = \"/tmp/xdebug.log\"\nxdebug.idekey = VSCODE" | sudo tee -a /etc/php/${php_ver}/mods-available/xdebug.ini)
    sudo systemctl restart apache2.service
   
    # check if xdebug appears in php version
    check=$(php -v | grep Xdebug)
    if [ ! -z "$check" ]
    then
        echo -e "\nXdebug installed successfully!\n"
    fi
    unset check
}

uninstall_php() {
    sudo apt purge 'php*' -y
    sudo apt autoclean && sudo apt autoremove -y
}

clear
echo -e "PHP Version Manager v0.01\nPress CTRL + C to finish the script\n\n"
echo -e "Checking if the ondrej/php PPA is present in source list...\n"

hasppa=$(ls /etc/apt/sources.list.d/ | grep "ondrej.*php")

if [ -z "$hasppa" ]
then
    echo -e "Importing ondrej/php PPA to install all PHP environments...\n"
    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt update
else
    echo -e "Your setup already has the ondrej/php PPA. Proceeding with the installation\n"
fi
unset hasppa

echo -e "There are the following versions available of PHP in this script:\n"
echo -e "[1] 8.1"
echo -e "[2] 7.4"
echo -e "[3] Do not install PHP"
echo -en "\nWhat do you choice to install: "
read -n1 pchoice

echo -e "\n"

case $pchoice in
    "1")
        php_ver="8.1"
        ;;
    "2")
        php_ver="7.4"
        ;;
    "3")
        php_ver=""
        echo -e "No PHP will be installed :D \n"
        ;;
    *)
        echo "Invalid option"
        exit 0
        ;;
esac
unset pchoice

if [ ! -z "$php_ver" ]
then
    echo -e "Installing PHP ${php_ver} with extensions\n"
    sudo apt install "php${php_ver}-cli" "php${php_ver}-curl" "php${php_ver}-mysqlnd" "php${php_ver}-gd" "php${php_ver}-opcache" "php${php_ver}-zip" "php${php_ver}-intl" "php${php_ver}-common" "php${php_ver}-bcmath" "php${php_ver}-imap" "php${php_ver}-imagick" "php${php_ver}-xmlrpc" "php${php_ver}-readline" "php${php_ver}-memcached" "php${php_ver}-redis" "php${php_ver}-mbstring" "php${php_ver}-apcu" "php${php_ver}-xml" "php${php_ver}-dom" "php${php_ver}-redis" "php${php_ver}-memcached" "php${php_ver}-memcache" "php${php_ver}-sqlite3" -y
    echo -en "\n Would you like to install xdebug also? [Y/n]: "
    read -n1 inst_xdebug
    echo -e "\n"
    
    if [ "${inst_xdebug,,}" = "y" ] || [ -z "$inst_xdebug" ]
    then
        echo -e "Installing xdebug...\n"
        install_xdebug
    else
        echo -e "\nNo xdebug will be installed ;)"
    fi
    unset inst_xdebug

fi
unset php_ver

# composer installation
echo -e "\nWould you like to install composer, remove previous installation and reinstall or do nothing?\n"
echo -e "[1] Install composer"
echo -e "[2] Reinstall composer"
echo -e "[3] Do nothing"
echo -en "\nChoice: "
read -n1 comp_choice
echo -e "\n"

case $comp_choice in
    "1")
        echo -e "Installing composer...\n"
        install_composer
        ;;
    "2")
        echo -e "Reinstalling composer...\n"
        sudo rm /usr/bin/composer
        install_composer
        ;;
    "3")
        echo -e "No composer will be installed :D \n"
        ;;
    *)
        echo "Invalid option"
        exit 0
        ;;
esac
unset comp_choice 
