#!/bin/bash
#
# Commented provisioning script for a flyimg server
# Created for Ubuntu 16 but works with 14 and possibly with other distributions
# This script is intended to be used as a root user
# This script should be ideally invoqued by a Cloud-init script 
# 	Read more at: https://www.digitalocean.com/community/tutorials/an-introduction-to-cloud-config-scripting#run-arbitrary-commands-for-more-control
# 	
# Original Gist at: https://gist.github.com/baamenabar/2a825178318d27fc20abfe5a413b45eb
# Author B. Agustin Amenabar L. @iminabar
# 

# The user must be the same set by the Cloud-init script
nixusr="leopold"

# We go in to the user's home folder and copy the authorized keys from root
cd /home/$nixusr/
if [ ! -d ".ssh" ]; then
  mkdir .ssh
fi
echo $(pwd)
chmod 777 .ssh
cat /root/.ssh/authorized_keys > .ssh/authorized_keys
chown -R $nixusr:$nixusr .ssh
chmod 600 .ssh/authorized_keys
chmod 700 .ssh

# We use sed to remove the possibility to log in as root user and to log in withour password.
sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
echo 'reconfigured sshd_config'

# we restart the ssh service to make the changes effective
service ssh restart
echo 'restarted ssh'
echo "You can now login with the user: $nixusr"

# We add the user to the docker group (the docker installation creates this group)
sudo usermod -aG docker $nixusr

# We clone the flyimg repo into the user's folder.
echo "cloning flyimg into " $(pwd)
sudo -HEu $nixusr git clone https://github.com/flyimg/flyimg.git /home/$nixusr/flyimg

# List the repo's content to comfirm it's there.
cd flyimg
echo "...cloned! content is:"
ls -la

# if we have the whitelist_domains.txt add the domains and activate the restriction
if [ -r /var/whitelist_domains.txt ]; then
    mv /var/whitelist_domains.txt whitelist_domains.txt
    chown -R $nixusr:$nixusr whitelist_domains.txt
    echo 'activating domain restriction'
    # activate the restricted domains config
    sudo -u $nixusr sed -i -e 's/restricted_domains: false/restricted_domains: true/' config/parameters.yml
    # remove the dummy domains
    sudo -u $nixusr sed -i -e '/www.domain-/d' config/parameters.yml
    # prepend yaml list format to the whitelist_domains.txt
    sudo -u $nixusr sed -i -e 's/^/    - /' whitelist_domains.txt
    echo 'setting whitelisted domains'
    cat whitelist_domains.txt
    # insert the domains into the config file
    sudo -u $nixusr sed -i '/whitelist_domains:/ r whitelist_domains.txt' config/parameters.yml
fi

# Build the docker container
echo "sudo -u $nixusr docker build -t flyimg ."
sudo -u $nixusr docker build -t flyimg .
sleep 5

# Run the container, naming it "flyimg" and exposing it through port 80
echo "sudo -u $nixusr docker run -t -d -i -p 80:80 -v /home/$nixusr/flyimg:/var/www/html --name flyimg flyimg"
sudo -u $nixusr docker run -t -d -i -p 80:80 -v /home/$nixusr/flyimg:/var/www/html --name flyimg flyimg
sleep 5

# Update the container to restart always in case of stopping for any reason.
# Even after the server has restarted
echo "sudo -u $nixusr docker update --restart=always flyimg"
sudo -u $nixusr docker update --restart=always flyimg

# list the container(s)
echo "sudo -u $nixusr docker ps"
sudo -u $nixusr docker ps
sleep 10

# Run composer inside the container image to download all the dependencies the application needs.
echo "sudo -HEu $nixusr docker exec -i flyimg composer install"
sudo -HEu $nixusr docker exec -i flyimg composer install

echo $'\n Horray! Provisioning finished \n Happy Imaging.'
