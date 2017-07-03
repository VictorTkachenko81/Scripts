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
echo " 11 - Cron Run"
echo -e "\nCurrent database: $MDB"

#bin/magento maintenance:status

echo -n -e "\nPlease choose > "

read input_command

function clean_pub_static {
    echo -e "\nClean pub/static folders..."
    rm -rf pub/static/_requirejs/*
    rm -rf pub/static/adminhtml/*
    rm -rf pub/static/frontend/*
}

function clean_var {
    echo -e "\nClean var folders..."
    rm -rf var/cache/*
    rm -rf var/di/*
    rm -rf var/generation/*
    rm -rf var/log/*
    rm -rf var/page_cache/*
    rm -rf var/report/*
    rm -rf var/tmp/*
    rm -rf var/view_preprocessed/*
}

function database_dump {
    echo -e "\nCreate dump of database..."
    mysqldump -u $MUSER -p $MDB --password=$MPASS > $DUMP
}

function database_refresh {
    echo -e "\nDrop tables in database..."
    mysql --host=$MHOST --user=$MUSER --password=$MPASS -BNe "show tables" --database=$MDB | tr '\n' ',' | sed -e 's/,$//' | awk '{print "SET FOREIGN_KEY_CHECKS = 0;DROP TABLE IF EXISTS " $1 ";SET FOREIGN_KEY_CHECKS = 1;"}' | mysql --host=$MHOST --user=$MUSER --password=$MPASS --database=$MDB
    echo -e "\nRefresh data in database..."
    mysql --host=$MHOST --user=$MUSER --password=$MPASS --database=$MDB < $DUMP
    echo -e "\nUpgrade database..."
    $PHP $MAGENTO setup:upgrade
    echo -e "\nReindexing..."
    $PHP $MAGENTO indexer:reindex
}

function deploy_static_content_all {
    deploy_static_content_adminhtml
    deploy_static_content_blank
    deploy_static_content_luma
}

function deploy_static_content_adminhtml {
    echo -e "\nDeploy adminhtml..."
    $PHP $MAGENTO setup:static-content:deploy --area adminhtml
}

function deploy_static_content_blank {
    echo -e "\nDeploy frontend theme blank..."
	$PHP $MAGENTO setup:static-content:deploy --area frontend --theme Magento/blank
}

function deploy_static_content_luma {
    echo -e "\nDeploy frontend theme luma..."
	$PHP $MAGENTO setup:static-content:deploy --area frontend --theme Magento/luma
}

case ${input_command} in
    0 )
        clean_pub_static
        clean_var
        database_refresh
        deploy_static_content_luma
        deploy_static_content_adminhtml
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
        echo " 3 - deploy static content all"
        echo " 4 - deploy static content adminhtml"
        echo " 5 - deploy static content blank"
        echo " 6 - deploy static content luma"
        echo -n -e "\nPlease choose > "

        read mode
        case ${mode} in
            0 )
                clean_pub_static
                clean_var
            ;;
            1 )
                clean_pub_static
            ;;
            2 )
                clean_var
            ;;
            3 )
                deploy_static_content_all
            ;;
            4 )
                deploy_static_content_adminhtml
            ;;
            5 )
                deploy_static_content_blank
            ;;
            6 )
                deploy_static_content_luma
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
                database_refresh
            ;;
            1 )
                echo -e "\nUpgrade database..."
                $PHP $MAGENTO setup:upgrade
            ;;
            2 )
                database_dump
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
        #https://github.com/squizlabs/PHP_CodeSniffer/wiki/Configuration-Options#setting-the-installed-standard-paths
        #vendor/bin/phpcs --config-set installed_paths /home/user/check-code
        #vendor/bin/phpcs --config-set m2-path /home/user/work/magento2/html
        #vendor/bin/phpcs /home/user/work/magento2/html/app/code/Mageside/EmailToCustomers --standard=MEQP2
        read project_directory

        echo -e "Show errors:\n"
        echo " 0 - All"
        echo " 1 - Level 1 of Magento Marketplace Technical Review"
        echo -n -e "\nPlease choose > "

        read errors
        case ${errors} in
            0 )
                $PHP $PHPCS --config-set m2-path $PWD
                $PHP $PHPCS app/code/Mageside/$project_directory --standard=MEQP2 --extensions=php,phtml
            ;;
            1 )
                $PHP $PHPCS --config-set m2-path $PWD
                $PHP $PHPCS app/code/Mageside/$project_directory --standard=MEQP2 --extensions=php,phtml --severity=10
            ;;
            * )
                echo "nothing to choose"
        esac
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
    11 )
        echo -e "\nMagento Cron Run"
        $PHP $MAGENTO cron:run
        ;;
    * )
        echo "Good bye!"
esac
