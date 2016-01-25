#!/usr/bin/env bash

echo -n "\nEnter virtual host name > "
read virtualHostName
virtualHostFileName="$virtualHostName.conf"

echo -n "\nEnter project directory > "
read projectDirectory

echo "\nYour project will be stored in $HOME/www/$projectDirectory/html directory"
echo -n "Enter root directory for index.php (Magento2:pub|Symfony:web)> "
read endPointDirectory
rootDirectory="/$endPointDirectory"

echo "<VirtualHost *:80>" >> ${virtualHostFileName}
echo "	ServerName $virtualHostName" >> ${virtualHostFileName}
echo "	DocumentRoot $HOME/www/$projectDirectory/html$rootDirectory" >> ${virtualHostFileName}
echo "	ErrorLog $HOME/www/$projectDirectory/logs/error.log" >> ${virtualHostFileName}
echo "	CustomLog $HOME/www/$projectDirectory/logs/access.log combined" >> ${virtualHostFileName}
echo "	<Directory $HOME/www/$projectDirectory/html$rootDirectory>" >> ${virtualHostFileName}
echo "	    DirectoryIndex index.php" >> ${virtualHostFileName}
echo "	    Options Indexes FollowSymLinks" >> ${virtualHostFileName}
echo "	    AllowOverride All" >> ${virtualHostFileName}
echo "		Require all granted" >> ${virtualHostFileName}
echo "	</Directory>" >> ${virtualHostFileName}
echo "</VirtualHost>" >> ${virtualHostFileName}

#mv ${virtualHostFileName} "/etc/apache2/sites-available/${virtualHostFileName}"
#
#echo "127.0.0.1 $virtualHostName" >> /etc/hosts
#
#a2ensite ${virtualHostFileName}
#
#service apache2 restart
#
#mkdir "$HOME/www/$projectDirectory"
#mkdir "$HOME/www/$projectDirectory/html"
#mkdir "$HOME/www/$projectDirectory/logs"
#
#chmod -R 0777 "$HOME/www/$projectDirectory"
#chown -hR victor:victor "$HOME/www/$projectDirectory"