# Provisioning scripts for Digitalocean

This pair of scripts will help you setup a server on a Dropplet in 5 minutes.

Paste the contents of the **[cloud-init-on-ubuntu.yml](https://raw.githubusercontent.com/Flyimg/DigitalOcean-provision/master/cloud-init-on-ubuntu.yml)** file on to the "User data" field when creating a new Ubuntu Dropplet.

Ideally you should also add any publick key you want to the root user snd the provisioning script will add it also to the first user so you can SSH in to the server once the dropplet is created.
