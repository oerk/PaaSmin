# install docker
apt-get update
apt-get install linux-image-generic-lts-raring linux-headers-generic-lts-raring 
curl https://get.docker.io/gpg | apt-key add -
echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y python-software-properties 
add-apt-repository ppa:dotcloud/lxc-docker
apt-get install -y  lxc-docker
# install route nginx wget sqlite3 vsftpd
apt-get install -y nginx wget sqlite3 vsftpd

apt-get install -y  libdb4.8-dev
# add runtime group
groupadd -g 500 www
# add web user
useradd -u 1001 -g 100   -d  /home/web  -s /bin/bash  -m  web

# add web env
chmod  550 /home/web
chown web:www /home/web
chown web:users /home/web/html
mkdir /home/web/logs
mkdir /home/web/doc
mkdir /home/web/conf/nginx
mkdir /home/web/conf/php
mkdir /home/web/conf/tomcat
chown web:users /home/web/doc
chown root:root /home/web/conf
chown root:root /home/web/logs


#Pull basic system contos
docker pull contos

# Generate basic nginx server from contos 
cd ../docker_nginx
docker  build   -t Paas/nginx .

# Generate basic nginx + php-fpm server from Paas/nginx 
cd ../docker_ngx_php
docker  build   -t Paas/nginx-php .


# Generate basic nginx + tomcat server from Paas/nginx 
#cd ../docker_ngx_tomcat
#docker  build   -t Paas/nginx-tomcat .
# install mojolicio
#curl get.mojolicio.us | sh
 wget http://vicerveza.homeunix.net/~viric/soft/ts/ts-0.7.3.tar.gz  -O /tmp/ts-0.7.3.tar.gz

tar xvfz /tmp/ts-0.7.3.tar.gz
cd ../ts-0.7.3
make 
make install 

# install cpanminus
apt-get install -y cpanminus

# install Module
#cpanm Config::General File::Spec Log::Log4perl  Template  DBI  List::Util List::MoreUtils Scalar::Util File::Spe Text::Flowchart DB_File JSON File::Pid AnyEvent::Redis
#cpanm Net::Docker 
