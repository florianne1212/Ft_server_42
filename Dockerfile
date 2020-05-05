FROM debian:buster
 
MAINTAINER fcoudert <fcoudert@student.42.fr>

RUN apt-get update && apt-get install -y nginx ; \
		apt-get install -y wget ; \
		apt-get install -y default-mysql-server ; \
		apt-get install -y php-fpm php-mysql php-cli php-curl php-gd php-intl ; \
		apt-get install -y php

RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz ; \
		tar xzvf phpMyAdmin-4.9.0.1-all-languages.tar.gz ; \
		mv phpMyAdmin-4.9.0.1-all-languages /var/www/html/phpmyadmin

RUN service mysql start ; \
		mysql -u root -e "CREATE DATABASE "wordpress" ;" ; \ 
		mysql -u root -e "CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'password'" ; \
		mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'newuser'@'localhost'"; \
		mysql -u root -e "FLUSH PRIVILEGES";

RUN wget http://wordpress.org/latest.tar.gz ; \
		tar xzvf latest.tar.gz ; \
		mv wordpress /var/www/html/wordpress ; \
		rm -f /var/www/html/wordpress/wp-config-sample.php

COPY srcs/wp-config.php /var/www/html/wordpress 

RUN chown -R www-data:www-data /var/www/html/wordpress/ ; \
		chmod -R 755 /var/www/html/wordpress

RUN openssl req -new -newkey rsa:2048 -nodes -x509 -subj '/C=FR/ST=IDF/L=PARIS/O=YourOrg/CN=www.yourorg.com' -days 3650 -keyout example.key -out example.crt ; \
		mv example.crt /etc/ ; \
		mv example.key /etc/

RUN rm -f /etc/nginx/sites-enabled/default
COPY srcs/my_site.conf /etc/nginx/sites-enabled
RUN sed -i 's/index_test/on/g' /etc/nginx/sites-enabled/my_site.conf
COPY srcs/accueil.html /var/www/html
RUN rm /var/www/html/index.nginx-debian.html


CMD service mysql start ; \
	service php7.3-fpm start ; \
	service nginx start ; \
	sleep infinity
