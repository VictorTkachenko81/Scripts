#!/bin/bash
#Documentation:
#http://devdocs.magento.com/guides/v2.0/extension-dev-guide/enable-module.html
#http://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-subcommands-enable.html#instgde-cli-subcommands-enable-disable
#Magento 2 plugin: https://plugins.jetbrains.com/plugin/8024

echo -e "\nWelcome to install script!\n"
echo "Choose what you want to do:"
echo " 1 - List enabled and disabled modules"
echo " 2 - Enable Module"
echo " 3 - Disable Module"
echo " 4 - Clear cache"
echo " 5 - Regenerate autoload files"
echo " 8 - Change mode"
echo " 9 - Set permission"
echo " 10 - Auto generate urn schemas for PhpStorm"
echo " 100 - Errors"
echo -e " 0 - exit\n"

bin/magento deploy:mode:show

echo -n -e "\nPlease choose > "

read input_command
echo ${input_command}

case ${input_command} in
    1 )
        bin/magento module:status
        ;;
    2 )
        echo "See more on http://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-subcommands-enable.html#instgde-cli-subcommands-enable-disable"
#        echo -n "Please enter ModuleName > "
#        read module_name
#        echo ${module_name}
#        bin/magento module:enable --clear-static-content ${module_name}
        bin/magento setup:upgrade
        ;;
    3 )
        echo "See more on http://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-subcommands-enable.html#instgde-cli-subcommands-enable-disable"
        echo -n "Please enter ModuleName > "
        read module_name
        echo ${module_name}
        bin/magento module:disable --clear-static-content ${module_name}
        ;;
    4 )
#        bin/magento cache:flush
        rm -rf var/generation/*
        rm -rf var/cache/*
        rm -rf var/page_cache
        ;;
    5 )
        composer dump-autoload
		;;
    8 )
        echo "See more on http://devdocs.magento.com/guides/v2.0/config-guide/bootstrap/magento-modes.html"
        echo -n "Please enter mode [dev|prod] > "
        read mode
        case ${mode} in
            dev )
                rm -rf var/di/* var/generation/*
                bin/magento deploy:mode:set developer
            ;;
            prod )
                bin/magento deploy:mode:set production --skip-compilation
            esac
		;;
    9 )
        echo "Change permission for folders 770 and 660 for files"
        find . -type d -exec chmod 770 {} \; && find . -type f -exec chmod 660 {} \; && chmod u+x bin/magento
		;;
	10 )
#	    ToDo: create script for finding .idea/misc.xml
        bin/magento dev:urn-catalog:generate ../.idea/misc.xml
		;;
	100 )
        echo " 1 - There are no commands defined in the “deploy:mode” namespace."
        echo -n "Please choose > "
        read error
        case ${error} in
            1 )
                echo "See on <a href='http://likescroll.com/magento-2-there-are-no-commands-defined-in-the-cron-namespace.html'>detail</a>"
            ;;
            2 )

            ;;
            0 )
                echo "Good bye!"
            esac
		;;
    0 )
        echo "Good bye!"
esac
