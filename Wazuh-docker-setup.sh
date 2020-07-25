#!/bin/bash
apt-get update &&apt-get upgrade -y

#Docker installation 
sudo apt-get remove docker docker-engine docker.io containerd runc -y

sudo apt-get update

sudo apt-get install apt-transport-https ca-certificates  curl gnupg-agent software-properties-common -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io -y

echo "/n/n********Docker installation Completed********/n/n"

docker version

echo "/n/n********Docker-Compose installation********/n/n"

sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose --version

#Increase max_map_count on your Docker host:

sysctl -w vm.max_map_count=262144


function clean_up {
    # Perform program exit housekeeping
    kill $CHILD_PID
    exit
}

trap clean_up SIGHUP SIGINT SIGTERM

rm -f nginx.conf

cp nginx_default.conf nginx.conf

docker-compose up --scale wazuh-worker=$1 --scale load-balancer=0 > services.logs &

CHILD_PID=$!

echo ";Waiting for services start.";

sleep 10

echo ";Creating load-balancer configuration";

MASTER_IP=$(docker-compose exec wazuh hostname -i)

sed -i -e ";s#<WAZUH-MASTER-IP>#${MASTER_IP::-1}#g" nginx.conf

for i in $(seq 1 $1)

do
    WORKER_IP=$(docker-compose exec --index=$i wazuh-worker hostname -i)
    
    sed -i -e ";s#NEXT_SERVER#server ${WORKER_IP::-1}:1514;\n\tNEXT_SERVER#g" nginx.conf
done

sed -i -e ";s#NEXT_SERVER##g" nginx.conf

echo ";Running load-balancer service";

docker-compose up load-balancer > load-balancer.logs 

wait $CHILD_PID

