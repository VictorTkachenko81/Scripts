#!/usr/bin/env bash

echo -e "\n Hello!\n"
echo " 1 - Ubuntu version"
echo " 2 - Composer install"

echo -n -e "\nPlease choose > "
read command


case ${command} in
    1 )
        echo -e "\nUbuntu version\n"
        lsb_release -a
    ;;
    2 )
        echo -e "\nComposer install\n"
        curl -sS https://getcomposer.org/installer | php
        mv composer.phar /usr/local/bin/composer
    ;;
    3 )
        echo "reserved"
    ;;
    4 )
        echo "reserved"
    ;;
    5 )
        echo "reserved"
    ;;
    6 )
        echo "reserved"
    ;;
    7 )
        echo "reserved"
    ;;
    8 )
        echo "reserved"
    ;;
    9 )
        echo "reserved"
    ;;
    10 )
        echo "reserved"
    ;;
    11 )
        echo "reserved"
    ;;
    * )
        echo "Good bye!"
    esac