FROM wordpress:latest

COPY wp_install.sh /usr/src/wordpress/wp_install.sh
COPY wp-config.php /var/www/html/wp-config.php

RUN chmod 777 /usr/src/wordpress/wp_install.sh

ENTRYPOINT ["/usr/src/wordpress/wp_install.sh"]
