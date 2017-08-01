FROM php:7.0-fpm

# install the PHP extensions we need

RUN set -ex; \
	\
	apt-get update; \
	apt-get install -y \
		libjpeg-dev \
		libpng-dev \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install gd mysqli
# TODO consider removing the *-dev deps and only keeping the necessary lib* packages


RUN { \
		echo 'file_uploads = On'; \
		echo 'memory_limit = 2G'; \
		echo 'upload_max_filesize = 10G'; \
		echo 'post_max_size = 10G'; \
		echo 'max_execution_time = 600'; \
	} > /usr/local/etc/php/conf.d/uploads.ini

RUN { \
		echo 'log_errors = On'; \
		echo 'error_reporting = E_ALL'; \
	} > /usr/local/etc/php/conf.d/errors.ini


VOLUME /var/www/html

ENV WORDPRESS_VERSION 4.8
ENV WORDPRESS_SHA1 3738189a1f37a03fb9cb087160b457d7a641ccb4

RUN set -ex; \
	curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"; \
	echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c -; \
# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
	tar -xzf wordpress.tar.gz -C /usr/src/; \
	rm wordpress.tar.gz; \
	chown -R www-data:www-data /usr/src/wordpress

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
