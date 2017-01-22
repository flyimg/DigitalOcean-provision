# Provisioning scripts for Digitalocean

This pair of scripts will help you setup a server on a Dropplet in 5 minutes.

Paste the contents of the **[cloud-init-on-ubuntu.yml](https://raw.githubusercontent.com/Flyimg/DigitalOcean-provision/master/cloud-init-on-ubuntu.yml)** file on to the "User data" field when creating a new Ubuntu Dropplet.

Ideally you should also add any publick key you want to the root user snd the provisioning script will add it also to the first user so you can SSH in to the server once the dropplet is created.

If you want to see the provisioning script in action you can SSH into the Dropplet as root as soon as it was created (given that you adde a key at creation time) and `tail` the cloud init log.

```
tail -f /var/log/cloud-init-output.log
```

There's deeper a tutorial on how to setup the droplet at: http://code.medula.cl/article_Fly-image-microserver-with-Docker-on-Digitalocean.html

... more info to come.
