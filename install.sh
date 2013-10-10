# install docker
apt-get update
apt-get install linux-image-generic-lts-raring linux-headers-generic-lts-raring 
curl https://get.docker.io/gpg | apt-key add -
echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y python-software-properties 
add-apt-repository ppa:dotcloud/lxc-docker
apt-get install -y  lxc-docker

# install mojolicio
curl get.mojolicio.us | sh

# install cpanminus
apt-get install -y cpanminus

# install Module
cpanm Config::General File::Spec Log::Log4perl  Template  DBI  List::Util List::MoreUtils Scalar::Util File::Spec 
#cpanm Net::Docker 
