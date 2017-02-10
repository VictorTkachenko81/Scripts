#!/usr/bin/env bash

mainProjectsDirectory="www";
userGroup="victor:victor";

echo -n "Enter virtual host name > ";
read virtualHostName;
virtualHostFileName="$virtualHostName.conf";

#echo -n "Enter project directory > ";
#read projectDirectory;
projectDirectory=$virtualHostName;

echo -n "Enter root directory for index.php (Magento2:pub|Symfony:web)> ";
read endPointDirectory;
rootDirectory="/$endPointDirectory";

echo -n "Index file in root directory (Magento2:index.php|Symfony:app.php)> ";
read indexFile;


echo "Before you continue, please check you parameters:";
echo "Host name: $virtualHostName";
echo "Project directory: $HOME/$mainProjectsDirectory/$projectDirectory/html";
echo "Project root directory: $HOME/$mainProjectsDirectory/$projectDirectory/html$rootDirectory";
echo "Project logs: $HOME/$mainProjectsDirectory/$projectDirectory/logs";
echo "Index file: $indexFile";


echo -n "Do you want to continue? (y|n)> ";
read continue;
case ${continue} in
    y )
        echo "<VirtualHost *:80>" >> ${virtualHostFileName};
        echo "  ServerName $virtualHostName" >> ${virtualHostFileName};
        echo "  DocumentRoot $HOME/$mainProjectsDirectory/$projectDirectory/html$rootDirectory" >> ${virtualHostFileName};
        echo "  ErrorLog $HOME/$mainProjectsDirectory/$projectDirectory/logs/error.log" >> ${virtualHostFileName};
        echo "  CustomLog $HOME/$mainProjectsDirectory/$projectDirectory/logs/access.log combined" >> ${virtualHostFileName};
        echo "  <Directory $HOME/$mainProjectsDirectory/$projectDirectory/html$rootDirectory>" >> ${virtualHostFileName};
        echo "      DirectoryIndex $indexFile" >> ${virtualHostFileName};
        echo "      Options Indexes FollowSymLinks" >> ${virtualHostFileName};
        echo "      AllowOverride All" >> ${virtualHostFileName};
        echo "      Require all granted" >> ${virtualHostFileName};
        echo "  </Directory>" >> ${virtualHostFileName};
        echo "</VirtualHost>" >> ${virtualHostFileName};

        mv ${virtualHostFileName} "/etc/apache2/sites-available/${virtualHostFileName}";

        echo "127.0.0.1 $virtualHostName" >> /etc/hosts;

        mkdir "$HOME/$mainProjectsDirectory/$projectDirectory";
        mkdir "$HOME/$mainProjectsDirectory/$projectDirectory/html";
        mkdir "$HOME/$mainProjectsDirectory/$projectDirectory/logs";

        a2ensite ${virtualHostFileName};

        service apache2 restart;

        chmod -R 0770 "$HOME/$mainProjectsDirectory/$projectDirectory";
        chown -hR $userGroup "$HOME/$mainProjectsDirectory/$projectDirectory";
        ;;
    * )
        echo "Good bye!";
esac
