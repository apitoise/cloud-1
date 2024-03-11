#!/bin/sh

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

cd /var/www/html

wp core download --locale=fr_FR --allow-root

wp config create --dbname="$WORDPRESS_DB_NAME" --dbuser="$WORDPRESS_DB_USER" --dbpass="$WORDPRESS_DB_PASSWORD" --locale=fr_FR --allow-root

wp core install --url=apitoise.rature.fr --title="Apitoise 42" --admin_user="$WORDPRESS_USER" --admin_password="$WORDPRESS_PASSWORD" --admin_email=admin@example.com --skip-email --allow-root

apache2-foreground
