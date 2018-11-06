#!/usr/bin/env bash

# Add the PHP 7 Repositories
sudo add-apt-repository ppa:ondrej/php

#If you’re missing add-apt-repository, like some plain systems are, 
echo -e "\ninstall it and then add-apt-repository ppa:ondrej/php"
sudo apt-get -y install software-properties-common
sudo apt-get -y install python-software-properties

# Update
sudo apt-get update

echo -e "\nInstall Git"
sudo apt-get install -y git

echo -e "\nInstall Nginx"
sudo apt-get -y install unzip zip nginx

echo -e "\nInstall PHP 7.2 FPM"
sudo apt-get -y install php7.2 php7.2-fpm php7.2-mysql php7.2-mbstring php7.2-xml php7.2-curl

echo -e "\nInstall PHP 7.1 FPM"
sudo apt-get -y install php7.1 php7.1-cli php7.1-common php7.1-json php7.1-opcache php7.1-mysql php7.1-mbstring php7.1-mcrypt php7.1-zip php7.1-fpm

echo -e "\nInstall PHP 7.0 FPM"
sudo apt-get -y install php7.0 php7.0-fpm php7.0-mysql php7.0-mbstring php7.0-xml php7.0-curl

echo -e "\nInstall PHP 5.5 FPM"
sudo apt-get -y install php5.6 php5.6-fpm

echo -e "\nRestart PHP"
sudo service php7.2-fpm restart
sudo service php7.1-fpm restart
sudo service php7.0-fpm restart
sudo service php5.6-fpm restart

passwordgen() {
    l=$1
    [ "$l" == "" ] && l=16
    tr -dc A-Za-z0-9 < /dev/urandom | head -c ${l} | xargs
}

mysqlpassword=$(passwordgen);
mysqlrootpassword=$(passwordgen);
mysqlusername=$(passwordgen);
mysqldatabase=$(passwordgen);

echo -e "\nUpdate"
sudo apt-get update

echo -e "\nSet MySql User, Password"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysqlrootpassword"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysqlrootpassword"

echo -e "\nInstall MySql"
sudo apt-get install -y mysql-server bsdutils libsasl2-modules-sql libsasl2-modules

sudo service mysql restart

# small cleaning of mysql access
mysql -u root -p"$mysqlrootpassword" -e "DELETE FROM mysql.user WHERE User='root' AND Host != 'localhost'";
mysql -u root -p"$mysqlrootpassword" -e "DELETE FROM mysql.user WHERE User=''";
mysql -u root -p"$mysqlrootpassword" -e "FLUSH PRIVILEGES";

# remove test table that is no longer used
mysql -u root -p"$mysqlrootpassword" -e "DROP DATABASE IF EXISTS test";

# Create Mysql Database
mysql -u root -p"$mysqlrootpassword" -e "CREATE DATABASE $mysqldatabase DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci";

# Create Mysql User
mysql -u root -p"$mysqlrootpassword" -e "CREATE USER '$mysqlusername'@'localhost' IDENTIFIED BY '$mysqlpassword'";
mysql -u root -p"$mysqlrootpassword" -e "CREATE USER '$mysqlusername'@'%' IDENTIFIED BY '$mysqlpassword'";

mysql -u root -p"$mysqlrootpassword" -e "GRANT ALL PRIVILEGES ON $mysqldatabase.* TO '$mysqlusername'@'localhost' IDENTIFIED BY '$mysqlpassword' WITH GRANT OPTION";
mysql -u root -p"$mysqlrootpassword" -e "GRANT ALL PRIVILEGES ON $mysqldatabase.* TO '$mysqlusername'@'%' IDENTIFIED BY '$mysqlpassword' WITH GRANT OPTION";
mysql -u root -p"$mysqlrootpassword" -e "FLUSH PRIVILEGES";

echo -e "\nInstall Composer"
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

echo -e "\nSetup HHVM"
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 B4112585D386EB94

echo -e "\nHHVM's repository"
sudo add-apt-repository "deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main"

echo -e "\nUpdate"
sudo apt-get update

echo -e "\nInstall HHVM"
sudo apt-get -y install hhvm

echo -e "\n Run script which makes the integration with Nginx"
sudo /usr/share/hhvm/install_fastcgi.sh

echo -e "\nConfig Nginx to know HHVM"
#Change on Nginx sites enabled ==> fastcgi_pass   127.0.0.1:9000;

echo -e "\nRemove default Nginx host"
rm -f /etc/nginx/sites-enabled/default

echo -e "\nCreate default host"
sudo mkdir -p /var/www/html/default

echo -e "\nCreate new default host"

cat <<EOF > /etc/nginx/sites-available/default
# Application with PHP 7.2
#
server {
	listen 80;
    listen 443 ssl http2;

	root /var/www/html/default/public;
	index index.php index.html;

	server_name lexscorp.com;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    charset utf-8;
    sendfile off;
    client_max_body_size 100m;

	location ~* \.php\$ {
		# With php-fpm unix sockets
		fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
		fastcgi_index	index.php;
		include			fastcgi_params;
		fastcgi_param   SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
		fastcgi_param   SCRIPT_NAME        \$fastcgi_script_name;

        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
	}

    location ~ /\.ht {
        deny all;
    }

}
EOF

sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

echo -e "\nRestart Nginx"
sudo service nginx restart

# Install Wget
sudo apt-get install -y wget

echo -e "\nDownload file system"
wget https://github.com/putheng/laravelbuild/archive/master.zip

# Unzip 
unzip master.zip

echo -e "\nMove file to public html"
mv laravelbuild-master/* /var/www/html/default/

echo -e "\nInstall dependency"
composer install -d /var/www/html/default

sudo chmod -R ug+rwx /var/www/html/default/bootstrap/cache
sudo chmod -R ug+rwx /var/www/html/default/storage 

# Other way
sudo chown -R $USER:www-data /var/www/html/default/storage
sudo chown -R $USER:www-data /var/www/html/default/bootstrap/cache

chmod -R 775 /var/www/html/default/storage
chmod -R 775 /var/www/html/default/bootstrap/cache

{
    echo "APP_NAME=lexscorp"
    echo "APP_ENV=production"
    echo "APP_KEY=base64:XOio3YUo8424Pt3E34pexetoEOWVbBHNIqhkM80iIVo="
    echo "APP_DEBUG=true"
    echo "APP_URL=http://lexscorp.com"
    echo "APP_BUILD_URL=lexscorp.com"
    echo ""
    echo "LOG_CHANNEL=stack"
    echo ""
    echo "DB_CONNECTION=mysql"
    echo "DB_HOST=127.0.0.1"
    echo "DB_PORT=3306"
    echo "DB_DATABASE=$mysqldatabase"
    echo "DB_USERNAME=$mysqlusername"
    echo "DB_PASSWORD=$mysqlpassword"
    echo ""
    echo "BROADCAST_DRIVER=log"
    echo "CACHE_DRIVER=file"
    echo "SESSION_DRIVER=file"
    echo "SESSION_LIFETIME=120"
    echo "QUEUE_DRIVER=database"
    echo ""
    echo "REDIS_HOST=127.0.0.1"
    echo "REDIS_PASSWORD=null"
    echo "REDIS_PORT=6379"
    echo ""
    echo "MAIL_DRIVER=smtp"
    echo "MAIL_HOST=smtp.mailtrap.io"
    echo "MAIL_PORT=2525"
    echo "MAIL_USERNAME=null"
    echo "MAIL_PASSWORD=null"
    echo "MAIL_ENCRYPTION=null"
    echo ""
    echo "PUSHER_APP_ID="
    echo "PUSHER_APP_KEY="
    echo "PUSHER_APP_SECRET="
    echo "PUSHER_APP_CLUSTER=mt1"
    echo ""
} >> /var/www/html/default/.env

php /var/www/html/default/artisan key:generate
php /var/www/html/default/artisan migrate
php /var/www/html/default/artisan db:seed

# Install Supervisor
sudo apt-get install -y supervisor

{
    echo "[program:laravel-worker]"
    echo "process_name=%(program_name)s_%(process_num)02d"
    echo "command=php /var/www/html/default/artisan queue:work --sleep=3 --tries=3"
    echo "autostart=true"
    echo "autorestart=true"
    echo "user=root"
    echo "numprocs=8"
    echo "redirect_stderr=true"
    echo "stdout_logfile=/var/www/html/default/worker.log"
} >> /etc/supervisor/conf.d/laravel-worker.conf


# give execute permission to config file
sudo chmod +x /etc/supervisor/conf.d/queue-worker.conf

# Reading for any new configurations
sudo supervisorctl reread

# Now supervisor know that there is new file 
# but we have to restart this supervisor service also.
sudo supervisorctl update

# Reload
sudo supervisorctl reload

{
    echo "MySQL Root Password      : $mysqlrootpassword"
    echo ""
    echo "MySQL System username   : $mysqlusername"
    echo "MySQL System Password   : $mysqlpassword"
    echo "MySQL System database : $mysqldatabase"
    echo ""
    echo "(theses passwords are saved in /root/passwords.txt)"
} >> /root/passwords.txt


