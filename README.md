Wazuh containers for Docker-compose

In this repository you will find the containers to run:

wazuh: It runs the Wazuh manager, Wazuh API and Filebeat (for integration with Elastic Stack).
Wazuh-worker: we will use Docker Compose to create various instances of one service: wazuh-worker, based on the default wazuh-manager service, which will be used as a master node in our cluster.




wazuh-kibana: Provides a web user interface to browse through alerts data. It includes Wazuh plugin for Kibana, that allows you to visualize agents configuration and status.
wazuh-nginx: Proxies the Kibana container, adding HTTPS (via self-signed SSL certificate) and Basic authentication.
wazuh-elasticsearch: An Elasticsearch container (working as a single-node cluster) using Elastic Stack Docker images. Be aware to increase the vm.max_map_count setting, as it's detailed in the Wazuh documentation.
In addition, a docker-compose file is provided to launch the containers mentioned above.

Elasticsearch cluster. In the Elasticsearch Dockerfile we can visualize variables to configure an Elasticsearch Cluster. These variables are used in the file config_cluster.sh to set them in the elasticsearch.yml configuration file. You can see the meaning of the node variables here and other cluster settings here.





# Wazuh-Docker-Compose

1).Run the script <<Wazuh-docker-setup.sh>> with Sudo.
  
       chmod +x Wazuh-docker-setup.sh
      ./Wazuh-docker-setup.sh  <Number of worker> <Email-Id> <Password>
  
  
