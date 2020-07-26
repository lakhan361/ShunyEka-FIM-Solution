#!/bin/bash

#Check if input is Provided or Not

if [ -z "$1" ]
  then
    printf "\nNumber of Wazuh-Worker needed : \n\n" ; exit 1 
fi

#Number of worker check
re='^[0-99]+$'
if ! [[ $1 =~ $re ]] ; then
   echo "Pass a valid number" >&2; exit 1
fi

#Check if email is provided or not
if [ -z "$2" ]
  then
    printf "\nEmail is not provided : \n\n"; exit 1
fi

#Email Validity
if echo "$2" | grep '^[a-zA-Z0-9]*@[a-zA-Z0-9]*\.[a-zA-Z0-9]*$' >/dev/null; then
    printf  "\nValid email.\n\n"
else
    echo "Email invalid"; exit 1
fi

#Check if email is provided or not
if [ -z "$3" ]
  then
    printf "\nPassword is not provided : \n\n"; exit 1
fi

#Input values
echo "Number of Worker node : $1"
echo "Email Address : $2"
echo "Password : $3"



printf  "\n\n*******Input Validation completed.***********\n\n"
printf  "\n\n*******Docker and Docker-Compose installation started.***********\n\n"


#Adding email and password in docker-compose.yml file
Email=$2
Password=$3
sed -i -e ";s#<Email-Id>#${Email::-1}#g" docker-compose.yml
sed -i -e ";s#<Password>#${Password::-1}#g" docker-compose.yml

#Docker installation process begin

apt-get update &&apt-get upgrade -y

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


printf  "\n\n*******Docker and Docker-Compose installation completed.***********\n\n"


printf  "\n\n*******Starting Wazuh installation.***********\n\n"


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
