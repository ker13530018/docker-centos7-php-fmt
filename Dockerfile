FROM centos:7

# install PHP and extensions
RUN yum clean all; yum -y update; \
    yum -y --enablerepo=remi,remi-php72 install php php-fpm php-cli supervisord \
    php-bcmath \
    php-dom \
    php-gd \
    php-json \
    php-mbstring \
    php-mcrypt \
    php-mysqlnd \
    php-opcache \
    php-pdo \
    php-pdo-dblib \
    php-pecl-geoip \
    php-pecl-memcache \
    php-pecl-memcached \
    php-pecl-redis \
    php-zip \
    yum clean all


# create /tmp/lib/php
RUN mkdir -p /tmp/lib/php/session; \
    mkdir -p /tmp/lib/php/wsdlcache; \
    mkdir -p /tmp/lib/php/opcache; \
    mkdir /root/.composer; \
    chmod 777 -R /tmp/lib/php

# add custom config
COPY ./php/php.ini /etc/php.ini
COPY ./php/www.conf /etc/php-fpm.d/www.conf

RUN /bin/supervisord --version

# install Composer and plugins
# RUN curl -sS https://getcomposer.org/installer | php
# RUN mv composer.phar /usr/local/bin/composer
# RUN chmod +x /usr/local/bin/composer

# Adding the configuration file of the nginx
ADD nginx.conf /etc/nginx/nginx.conf

ADD default.conf /etc/nginx/conf.d/default.conf

ADD index.php /var/www/html/index.php

# Adding the configuration file of the Supervisor
COPY ./supervisord.conf /etc/supervisord.conf

# Set the port to 80 
EXPOSE 80

VOLUME ["/etc/nginx/conf.d", "/var/www/html" , "/var/log/php-fpm", "/var/log/nginx" ]

# Executing supervisord
CMD ["/bin/supervisord" , "-n"]