#!/bin/bash
#Documentation:
#http://devdocs.magento.com/guides/v2.0/extension-dev-guide/enable-module.html
#http://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-subcommands-enable.html#instgde-cli-subcommands-enable-disable
#Magento 2 plugin: https://plugins.jetbrains.com/plugin/8024

echo -e "\nWelcome to install script!\n"
echo "Choose what you want to do:"
echo " 0 - Start"
echo " 4 - Clear cache"
echo " 7 - "
echo " 8 - Change mode"
echo " 11 - Regenerate/resize cache of images"
echo " 12 - Find"
echo " 100 - Errors"

#bin/magento maintenance:status

echo -n -e "\nPlease choose > "

read input_command
echo ${input_command}

case ${input_command} in
    0 )
        echo " 0 - Install community"
        echo " 1 - Command list"
        echo " 2 - List enabled and disabled modules"
        echo " 3 - Enable Module"
        echo " 4 - Disable Module"
        echo " 5 - Regenerate autoload files"
        echo " 6 - Install sample data"
        echo " 7 - Set permission"
        echo " 8 - Auto generate urn schemas for PhpStorm"
        echo -n -e "\nPlease choose > "
        read mode
        case ${mode} in
            0 )
                composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition
            ;;
            1 )
                bin/magento --list
            ;;
            2 )
                bin/magento module:status
            ;;
            3 )
                echo "See more on http://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-subcommands-enable.html#instgde-cli-subcommands-enable-disable"
                echo -n "Please enter ModuleName > "
                read module_name
                echo ${module_name}
                bin/magento module:enable --clear-static-content ${module_name}
                bin/magento setup:upgrade
            ;;
            4 )
                echo "See more on http://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-subcommands-enable.html#instgde-cli-subcommands-enable-disable"
                echo -n "Please enter ModuleName > "
                read module_name
                echo ${module_name}
                bin/magento module:disable --clear-static-content ${module_name}
            ;;
            5 )
                composer dump-autoload
            ;;
            6 )
                echo "See more on http://devdocs.magento.com/guides/v2.0/install-gde/install/sample-data-after-magento.html"
                echo -n "Please choose [install|reset|remove] > "
                read mode
                case ${mode} in
                    install )
                        bin/magento sampledata:deploy
                    ;;
                    reset )
                        bin/magento sampledata:reset
                    ;;
                    remove )
                        bin/magento sampledata:remove
                    esac
                composer update
                bin/magento setup:upgrade
            ;;
            7 )
                echo "Change permission for folders 770 and 660 for files"
                find . -type d -exec chmod 770 {} \; && find . -type f -exec chmod 660 {} \; && chmod u+x bin/magento
            ;;
            8 )
                #ToDo: create script for finding .idea/misc.xml
                bin/magento dev:urn-catalog:generate ../.idea/misc.xml
            ;;
            9 )
#bin/magento setup:install --base-url=http://magetest2.local.com/ \
#--db-host=localhost --db-name=magento --db-user=magento --db-password=magento \
#--admin-firstname=Magento --admin-lastname=User --admin-email=user@example.com \
#--admin-user=admin --admin-password=admin123 --language=en_US \
#--currency=USD --timezone=America/Chicago --use-rewrites=1
            ;;
            10 )

            ;;
            * )
                echo "nothing to choose"
        esac
        ;;
    1 )

        ;;
    2 )

        ;;
    3 )

        ;;
    4 )
        echo " 1 - bin/magento cache:clean"
        echo " 2 - bin/magento cache:flush"
        echo " 3 - clean cache folders"
        echo " 4 - clean static folder"
        echo " 5 - clean generation folder"
        echo " 6 - clean css folder"
        echo " 7 - clean all cache folders"
        echo -n -e "\nPlease choose > "
        read mode
        case ${mode} in
            1 )
                bin/magento cache:clean
            ;;
            2 )
                bin/magento cache:flush
            ;;
            3 )
                echo "Clear cache"
                rm -rf var/cache/*
                rm -rf var/page_cache/*
            ;;
            4 )
                echo "Clear static pages"
                rm -rf pub/static/*

                echo "Regenerate static content"
                bin/magento setup:static-content:deploy
            ;;
            5 )
                echo "Clear generated clases"
                rm -rf var/generation/*
            ;;
            6 )
                echo -n -e "\nPlease choose theme path like Magento/luma> "
                read folder

                echo "Clear static pages"
                rm -rf pub/static/frontend/${folder}/en_US/css/*

                echo "Clear source files"
                rm -rf var/view_preprocessing/*

                echo "Regenerate static content"
                bin/magento setup:static-content:deploy
            ;;
            7 )
                echo "Clear cache"
                rm -rf var/cache/*
                rm -rf var/page_cache/*

                echo "Clear static pages"
                rm -rf pub/static/*

                echo "Clear generated clases"
                rm -rf var/generation/*

                echo "Clear source files"
                rm -rf var/view_preprocessing/*

                echo "Regenerate static content"
                bin/magento setup:static-content:deploy
            ;;
            8 )

            ;;
            * )
                echo "nothing to choose"
        esac

        ;;
    5 )

		;;
    6 )

		;;
    7 )

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

		;;
	10 )

		;;
	11 )
	    echo "new cache in /pub/media/catalog/product/cache in accordance with image metadata in view.xml configuration file"
        bin/magento catalog:images:resize
		;;
	12 )
	    echo -n "What you want to find [css|layout] > "
        read mode
        case ${mode} in
            css )echo "
<current_theme_dir>/web/css/
<current_theme_dir>/<Namespace>_<Module>/web/css/
<parent_theme_dir>/web/css/ (show in theme.xml in parent node)
<module_dir>/view/frontend/web/css/
<module_dir>/view/base/web/css/"
            ;;
            layout )echo "
<current_theme_dir>/<Namespace>_<Module>/layout/
<parent_theme(s)_dir>/<Namespace>_<Module>/layout/ (show in theme.xml in parent node)
<module_dir>/view/frontend/layout/
<module_dir>/view/base/layout/"
            ;;
            email )echo "
http://devdocs.magento.com/guides/v2.0/frontend-dev-guide/templates/template-email.html
admin/marketing/email templates
header/footer <module_email>/<view>/<area><email>
content <module_*sales*>/<view>/<area><email>"
            ;;
            3 )

            ;;
            4 )

            esac
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
    * )
        echo "Good bye!"
esac
