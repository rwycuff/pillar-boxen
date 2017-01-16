#!/bin/sh
progress_bar() {
  SECS=120
  while [[ 0 -ne $SECS ]]; do
    echo ".\c"
    sleep 1
    SECS=$[$SECS-1]
  done
  echo "\nTime is up, moving on."
}

echo "* Initializing Build machine"
echo "** shutting boot2docker down"
boot2docker down
echo "** deleting existing boot2docker images"
boot2docker delete

echo "** initialize boot2docker"
boot2docker init

echo "** increasing boot2docker memory"
VBoxManage modifyvm boot2docker-vm --memory 8192
echo "** exposing stash port to the outside world"
VBoxManage modifyvm boot2docker-vm --natpf1 'stash-http-7990,tcp,,7990,,7990'
echo "** exposing nexus port to the outside world"
VBoxManage modifyvm boot2docker-vm --natpf1 'nexus-http-8081,tcp,,8081,,8081'
echo "** exposing jenkins port to the outside world"
VBoxManage modifyvm boot2docker-vm --natpf1 'jenkins-http-8080,tcp,,8080,,8080'
echo "** exposing jenkins SLAVE port to the outside world"
VBoxManage modifyvm boot2docker-vm --natpf1 'jenkins-http-50000,tcp,,50000,,50000'

echo "** boot2docker startup"
boot2docker up --vbox-share=disable
$(boot2docker shellinit)
boot2docker ip

echo "* enable host nfs daemon for /Users"
echo "/Users -mapall=`whoami`:staff `boot2docker ip`\n" >> exports
# the /opt/boxen nfs mount is required for jenkins to find android sdk
echo "* enable host nfs daemon for /opt/boxen"
echo "/opt/boxen -mapall=`whoami`:staff `boot2docker ip`\n" >> exports
sudo mv exports /etc && sudo nfsd restart
sleep 15

echo "* enable boot2docker nfs client"
boot2docker ssh 'echo -e "#! /bin/bash\n\
sudo mkdir /Users
sudo mkdir -p /opt/boxen
sudo chown docker:staff /Users
sudo chown docker:staff /opt/boxen
# start nfs client
sudo /usr/local/etc/init.d/nfs-client start\n\
# mount /Users to host /Users
sudo mount 192.168.59.3:/Users /Users -o rw,async,noatime,rsize=32768,wsize=32768,proto=tcp\n\
sudo mount 192.168.59.3:/opt/boxen /opt/boxen -o rw,async,noatime,rsize=32768,wsize=32768,proto=tcp" > ~/bootlocal.sh'
boot2docker ssh 'sudo cp ~/bootlocal.sh /var/lib/boot2docker/'
boot2docker ssh 'ls -ltra /var/lib/boot2docker/'
boot2docker ssh '. /var/lib/boot2docker/bootlocal.sh'
echo "* display mounted nfs share"
boot2docker ssh mount
boot2docker ssh 'ls -ltra /Users'

echo "* defining directory for data shares (must be under the above nfs share)"
DATA_DIR=/Users/Shared/data
mkdir -p $DATA_DIR

echo "** docker stash startup"
if [ "$#" -eq 1 ] && [ -f $1 ]
then
  echo "* base stash image provided -> untar'ing $1 to $DATA_DIR/stash"
  rm -rf $DATA_DIR/stash
  mkdir -p $DATA_DIR/stash
  cd $DATA_DIR/stash
  tar xvf $1 
else
  echo "* base stash image NOT provided -> assuming default"
  mkdir -p $DATA_DIR/stash
fi
docker run --name=stash -d -v $DATA_DIR/stash:/var/atlassian/application-data/stash -p 7990:7990 -p 7999:7999 atlassian/stash
docker ps

echo "** setting docker timezone to EST"
ENV TZ=America/New_York

echo "** docker nexus startup"
mkdir -p $DATA_DIR/nexus
docker run --name nexus -d -v $DATA_DIR/nexus:/sonatype-work -p 8081:8081 sonatype/nexus 
docker ps

echo "* wait for stash to startup"
progress_bar

echo "** docker jenkins startup"

read -p "clone jenkins from stash?: (y/n) [Y]" CLONE_JENKINS
CLONE_JENKINS=${CLONE_JENKINS:-y}

if [ "$CLONE_JENKINS" = y ]
then
  echo "* cloning jenkins"
  rm -rf $DATA_DIR/jenkins
  mkdir -p $DATA_DIR/jenkins
  echo "* clone jenkins config"
  git clone http://admin@localhost:7990/scm/mls/jenkins_base_config.git /Users/Shared/data/jenkins
  echo "* clone jenkins jobs"
  git clone http://admin@localhost:7990/scm/mls/jenkins_jobs.git /Users/Shared/data/jenkins/jobs
else
  echo "* using existing jenkins data dir"
fi

docker run --add-host stash:192.168.8.31 --add-host nexus:192.168.8.31 --name jenkins -d -v $DATA_DIR/jenkins:/var/jenkins_home -v /opt/boxen:/opt/boxen -p 8080:8080 -p 50000:50000 jenkins 
docker ps

echo "** open stash browser"
open http://localhost:7990/
echo "** open nexus browser"
open http://localhost:8081/
echo "** open jenkins browser"
open http://localhost:8080/
