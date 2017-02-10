#!/bin/bash

MHOST="localhost"
MUSER="root"
MPASS="root"
MAGENTO="bin/magento"
PHP="php"
ENVPHP='app/etc/env.php'
MDB=`cat $ENVPHP | grep dbname | tail -1 | cut -d \' -f 4`
#DUMP="backup/local.sql"
DUMP="backup/$MDB.sql"
PHPCS="/home/victor/Modules/PHP_CodeSniffer/scripts/phpcs"

echo -e "\nMagento 2 script.\n"
echo "Choose what you want to do:"
echo " 0 - Clean Project"
echo " 1 - Modules"
echo " 2 - Cache"
echo " 3 - Database"
echo " 4 - Indexes"
echo " 5 - Permissions"
echo " 6 - Translate"
echo " 7 - Check Code"
echo " 8 - Check di"
echo " 9 - Magento Upgrade"
echo " 10 - Magento Admin User Create"
echo -e "\nCurrent database: $MDB"

#bin/magento maintenance:status

echo -n -e "\nPlease choose > "

read input_command

case ${input_command} in
    0 )
        rm -rf pub/static/_requirejs/*
        rm -rf pub/static/adminhtml/*
        rm -rf pub/static/frontend/*
        rm -rf var/cache/*
        rm -rf var/di/*
        rm -rf var/generation/*
        rm -rf var/log/*
        rm -rf var/page_cache/*
        rm -rf var/report/*
        rm -rf var/tmp/*
        rm -rf var/view_preprocessed/*
        mysql --host=$MHOST --user=$MUSER --password=$MPASS -BNe "show tables" --database=$MDB | tr '\n' ',' | sed -e 's/,$//' | awk '{print "SET FOREIGN_KEY_CHECKS = 0;DROP TABLE IF EXISTS " $1 ";SET FOREIGN_KEY_CHECKS = 1;"}' | mysql --host=$MHOST --user=$MUSER --password=$MPASS --database=$MDB
        mysql --host=$MHOST --user=$MUSER --password=$MPASS --database=$MDB < $DUMP
        $PHP $MAGENTO setup:upgrade
        $PHP $MAGENTO setup:static-content:deploy --area adminhtml
        ;;
    1 )
        $PHP $MAGENTO module:status

        echo -e "\n"
        echo " 1 - Enable module"
        echo " 2 - Disable module"
        echo -n -e "\nPlease choose > "

        read mode
        case ${mode} in
            1 )
                echo "See more on http://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-subcommands-enable.html#instgde-cli-subcommands-enable-disable"
                echo -n "Please enter ModuleName > "
                read module_name
                echo ${module_name}
                $PHP $MAGENTO module:enable --clear-static-content ${module_name}
                $PHP $MAGENTO setup:upgrade
            ;;
            2 )
                echo "See more on http://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-subcommands-enable.html#instgde-cli-subcommands-enable-disable"
                echo -n "Please enter ModuleName > "
                read module_name
                echo ${module_name}
                $PHP $MAGENTO module:disable --clear-static-content ${module_name}
            ;;
            * )
                echo "nothing to choose"
        esac
        ;;
    2 )
        echo -e "\n"
        echo " 0 - clean all folders"
        echo " 1 - clean static data"
        echo " 2 - clean var cache"
        echo " 3 - deploy adminhtml"
        echo " 4 - deploy frontend"
        echo -n -e "\nPlease choose > "

        read mode
        case ${mode} in
            0 )
                echo -e "\nClean pub, var folders..."
                rm -rf pub/static/_requirejs/*
                rm -rf pub/static/adminhtml/*
                rm -rf pub/static/frontend/*
                rm -rf var/cache/*
                rm -rf var/di/*
                rm -rf var/generation/*
                rm -rf var/log/*
                rm -rf var/page_cache/*
                rm -rf var/report/*
                rm -rf var/tmp/*
                rm -rf var/view_preprocessed/*
            ;;
            1 )
                echo -e "\nClean pub folder..."
                rm -rf pub/static/_requirejs/*
                rm -rf pub/static/adminhtml/*
                rm -rf pub/static/frontend/*
            ;;
            2 )
                echo -e "\nClean var folder..."
                rm -rf var/cache/*
                rm -rf var/di/*
                rm -rf var/generation/*
                rm -rf var/log/*
                rm -rf var/page_cache/*
                rm -rf var/report/*
                rm -rf var/tmp/*
                rm -rf var/view_preprocessed/*
            ;;
            3 )
                echo -e "\nDeploy adminhtml..."
                $PHP $MAGENTO setup:static-content:deploy --area adminhtml
            ;;
            4 )
                echo -e "\nDeploy frontend..."
                $PHP $MAGENTO setup:static-content:deploy --theme Magento/luma --area frontend
            ;;
            * )
                echo "nothing to choose"
        esac
        ;;
    3 )
        echo -e "\n"
        echo " 0 - Reload"
        echo " 1 - Upgrade"
        echo " 2 - Dump"
        echo -n -e "\nPlease choose > "

        read mode
        case ${mode} in
            0 )
#                echo -n -e "\nPlease enter database name > "
#                read MDB
                echo -e "\nDrop tables in database..."
                mysql --host=$MHOST --user=$MUSER --password=$MPASS -BNe "show tables" --database=$MDB | tr '\n' ',' | sed -e 's/,$//' | awk '{print "SET FOREIGN_KEY_CHECKS = 0;DROP TABLE IF EXISTS " $1 ";SET FOREIGN_KEY_CHECKS = 1;"}' | mysql --host=$MHOST --user=$MUSER --password=$MPASS --database=$MDB
                echo -e "\nRefresh data in database..."
                mysql --host=$MHOST --user=$MUSER --password=$MPASS --database=$MDB < $DUMP
                echo -e "\nUpgrade database..."
                $PHP $MAGENTO setup:upgrade
            ;;
            1 )
                echo -e "\nUpgrade database..."
                $PHP $MAGENTO setup:upgrade
            ;;
            2 )
#                echo -n -e "\nPlease enter database name > "
#                read MDB
#                mysqldump --host=$MHOST --user=$MUSER --password=$MPASS --database=$MDB > "$MDB.sql"
                echo -e "\nCreate dump of database..."
                mysqldump -u $MUSER -p $MDB --password=$MPASS > $DUMP
            ;;
            * )
                echo "nothing to choose"
        esac
        ;;
    4 )
        $PHP $MAGENTO indexer:reindex
        ;;
    5 )
        find var vendor pub/static pub/media app/etc -type f -exec chmod g+w {} \;
        find var vendor pub/static pub/media app/etc -type d -exec chmod g+w {} \;
        chmod u+x bin/magento
        ;;
    6 )
        echo -n "Please enter project directory > app/code/"
        read project_directory
        mkdir "app/code/$project_directory/i18n/"
        $PHP $MAGENTO i18n:collect-phrases --output="app/code/$project_directory/i18n/en_US.csv" app/code/$project_directory/
        ;;
    7 )
        echo -n "Please enter project directory > app/code/Mageside/"
        read project_directory
        $PHP $PHPCS --config-set m2-path ''
        $PHP $PHPCS app/code/Mageside/$project_directory --extensions=php,phtml
        ;;
    8 )
        $PHP $MAGENTO setup:di:compile
        ;;
    9 )
        echo -n "Please enter Magento version you want to upgrade to > "
        read magento_version
        composer require magento/product-community-edition $magento_version --no-update
        composer update
        echo -e "\nUpgrade database..."
        $PHP $MAGENTO setup:upgrade
        ;;
    10 )
        echo -e "\nCreate Magento 2 Admin User"
        echo -n "Please enter email > "
        read admin_email
        echo -n "Please enter login > "
        read admin_login
        echo -n "Please enter password > "
        read admin_pass
        $PHP $MAGENTO admin:user:create --admin-firstname=$admin_login --admin-lastname=$admin_login --admin-email=$admin_email --admin-user=$admin_login --admin-password=$admin_pass
        ;;
    * )
        echo "Good bye!"
esac
