# nginx + php-fpm 
# Version 0.1

FROM Paas/nginx

MAINTAINER oerk 01oker@gmai.com

RUN yum  install  php-bcmath  php-cli  php-common  php-dba  php-devel  php-embedded  php-enchant  php-fpm  php-gd  php-imap  php-intl  php-ldap  php-mbstring  php-mcrypt  php-mysql  php-mysqlnd  php-odbc  php-pdo  php-pear  php-pear.noarch  php-pecl-apc  php-pecl-apc-devel  php-pecl-memcache  php-pecl-memcached  php-pecl-mongo  php-pecl-redis  php-pgsql  php-process  php-pspell  php-recode  php-snmp  php-soap  php-sqlite  php-tidy  php-xml  php-xmlrpc  php-zts  rrdtool-php  uuid-php  


RUN sed -i 's/;date.timezone =/date.timezone = Asia\/Shanghai/g' /etc/php.ini 

RUN mkdir -p /var/php/conf
RUN cp /etc/php.ini /var/php/conf 

ADD start.sh /start.sh
RUN chmod +x /start.sh
ADD fpm.conf /etc/php-fpm.d/fpm.conf
RUN rm -rf /etc/php-fpm.d/www.conf
 
CMD ["/start.sh"]










