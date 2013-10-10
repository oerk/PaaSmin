# nginx 
# Version 0.1

FROM centos:6.4

MAINTAINER oerk 01oker@gmai.com

# Remi Dependency on CentOS 6 and Red Hat (RHEL) 6 ##
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
 
# CentOS 6 and Red Hat (RHEL) 6 ##
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

ADD nginx.repo /etc/yum.repos.d/nginx.repo

RUN echo "root:123456" | chpasswd 
#add www group
RUN groupadd  -g 500 www 

useradd -u 1001 -g 100   -d  /home/web  -s /bin/bash  -m  web

RUN yum --enablerepo=remi,remi-test install nginx  openssh-server  -y

RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config 

RUN mkdir -p /var/www/ && chmod 755 /var/www/ 
#RUN chown -R  web:www  /var/www/ 

ADD .bash_profile   /root/.bash_profile
ADD .bashrc /root/.bashrc
ADD start.sh /start.sh
ADD iptables /etc/sysconfig/iptables
RUN chmod +x /start.sh

EXPOSE  22
EXPOSE  80
 
CMD ["/start.sh"]










