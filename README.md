Wazuh containers for Docker-compose
In this repository you will find the containers to run:

1). wazuh-manager: It runs the Wazuh manager, Wazuh API and Filebeat (for integration with Elastic Stack).
2). Wazuh-worker: we will use Docker Compose to create various instances of one service: wazuh-worker, based on the default wazuh-manager service, which will be used as a master node in our cluster.
3). Wazuh-kibana: Provides a web user interface to browse through alerts data. It includes Wazuh plugin for Kibana, that allows you to visualize agents configuration and status.
4). Wazuh-nginx: Proxies the Kibana container, adding HTTPS (via self-signed SSL certificate) and Basic authentication.
5). Wazuh-elasticsearch: An Elasticsearch container (working as a single-node cluster) using Elastic Stack Docker images. Be aware to increase the vm.max_map_count setting, as it's detailed in the Wazuh documentation.
6). Wazuh-loadbalancer: In our cluster documentation, Nginx could be a perfect tool to do load balancing.
7). Wazuh-Postfix: Sending email notification.


# Wazuh-Docker-Compose

1).Run the script <<Wazuh-docker-setup.sh>> with Sudo.
  
       chmod +x Wazuh-docker-setup.sh
      ./Wazuh-docker-setup.sh  <Number of worker> <Email-Id> <Password>
  
  
