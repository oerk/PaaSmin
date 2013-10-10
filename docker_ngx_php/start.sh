#!/bin/bash
service sshd restart
service iptables restart
service nginx restart
service php-fpm -c /var/php/conf/php.ini  restart
tail -f /dev/null
