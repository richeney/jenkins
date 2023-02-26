# Enabled TLS/SSL for Jenkins

Work in progress. Leaning heavily on

* <https://www.genja.co.uk/blog/installing-jenkins-and-securing-the-traffic-with-tls-ssl/>
* <https://github.com/smertan/jenkins>
* <https://learn.microsoft.com/en-us/azure/load-balancer/howto-load-balancer-imds?tabs=linux>
* <https://learn.microsoft.com/en-us/azure/virtual-machines/instance-metadata-service?tabs=linux>

* <https://drtailor.medium.com/how-to-set-up-https-for-jenkins-with-a-self-signed-certificate-on-ubuntu-20-04-2813ef2df537>

Skipping the ufw config as we have an NSG. The blog is worth reading to understand the commands.

## Open up the NSG

1. Check port 8080 is open on the NSG

    Port 8080 should already be open if the main README has been followed. If not:

    ```bash
    az vm open-port --port 8080 --priority 1010 --resource-group jenkins --name jenkins
    ```

1. Open up 8443

    This will be our SSL port.

    ```bash
    az vm open-port --port 8443 --priority 1020 --resource-group jenkins --name jenkins
    ```

    > For testing. Would recommend more granular NSG inbound security rules with source IP list, or use Bastion, preferably with AAD (and MFA). Can tunnel direct through to a specific port.

1. SSH to the Jenkins server

1. Grab the public IP address

    ```bash
    publicIp=$(az vm show --resource-group jenkins --name jenkins  --show-details --query publicIps --output tsv)
    echo $publicIp
    ```

1. SSH onto the Jenkins server

    ```bash
    ssh azureuser@$publicIp
    ```

1. Install nginx

    ```bash
    sudo apt update && sudo apt install nginx -y
    ```

1. Determine the public IP address using the load balancer Instance Metadata Service

    ```bash
    curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text"
    ```

    ```bash
    ipAddress=$(curl -sSL -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/loadbalancer?api-version=2020-10-01" \
      | jq -r .loadbalancer.publicIpAddresses[0].frontendIpAddress)
    echo $ipAddress
    ```

1. Create the self signed cert

    ```bash
    openssl_selfsigned_conf="https://raw.githubusercontent.com/richeney/jenkins/main/tls-ssl/openssl_selfsigned.conf"
    wget -qO- $openssl_selfsigned_conf \
      | sed -r "s/^(IP.1   = ).*/\1 $ipAddress/" \
      > openssl_selfsigned.conf
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/ssl/private/nginx-selfsigned.key \
      -out /etc/ssl/certs/nginx-selfsigned.crt \
      -config openssl_selfsigned.conf
    ```

1. Generate a Diffie Hellman group

    ```bash
    sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
    ```

1. Configure nginx

    ```bash
    sudo tee sudo vim /etc/nginx/snippets/self-signed.conf <<EOF
    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
    EOF
    sudo wget -qO /etc/nginx/snippets/ssl-params.conf \
      https://raw.githubusercontent.com/richeney/jenkins/main/tls-ssl/nginx/ssl-params.conf
    wget -q https://raw.githubusercontent.com/richeney/jenkins/main/tls-ssl/nginx/jenkins
    sed -i.bak "s/<yourServerAddress>/${ipAddress}/g" jenkins
    sudo mv jenkins /etc/nginx/sites-available/jenkins
    sudo rm /etc/nginx/sites-enabled/default
    sudo nginx -t
    ```

1. Modify /etc/default/jenkins

    ```bash
    sudo sed -i.bak -r 's/(^JENKINS_ARGS=".*\$HTTP_PORT)"$/\1 --httpListenAddress=127.0.0.1"/' /etc/default/jenkins
    cat /etc/default/jenkins
    ```

    The last line should now look like:

    ```text
    JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT --httpListenAddress=127.0.0.1"
    ```

1. Restart the services

    ```bash
    sudo systemctl restart nginx jenkins
    ```

1. Show the status

    ```bash
    sudo systemctl status jenkins nginx
    ```

    Break with `CTRL`+`C`.

1. Display public UI address

    ```bash
    ipAddress=$(curl -sSL -H Metadata:true --noproxy "*" http://169.254.169.254/metadata/loadbalancer?api-version=2020-10-01 \
      | jq -r .loadbalancer.publicIpAddresses[0].frontendIpAddress)
    echo "https://$ipAddress:8443"
    ```
