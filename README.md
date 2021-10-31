[![Deploy to DigitalOcean](https://github.com/dvillaj/NoSQL-Services/actions/workflows/deploy-digitalocean.yml/badge.svg)](https://github.com/dvillaj/NoSQL-Services/actions/workflows/deploy-digitalocean.yml)

# NoSQL-Services

This repo contains all the scripts needed to set up a Ubuntu box with several NoSQL Databases and a Jupyter environment to play with them

## Services

- Postgres
- Riak
- Cassandra
- Mongodb
- Neo4j
- Glances
- Portainer
- JupyterLab

Most of the services are powered by Docker and Docker Compose.

## Machine Requeriments

A machine with Ubuntu is needed to deploy all these services.

The requirements are:

 - 20.04 Ubuntu Server
 - At least 2 Gb of Memory
 - Local RSA SSH key to remote access


## Deployment

There are two possibilities:

 - A box deployed in your local machine with Vagrant & VirtualBox:  https://github.com/dvillaj/NoSQL-box
 - A box deployed with a Cloud Provider like [DigitalOcean](https://www.digitalocean.com) or similar (Azure, Google, AWS, etc.) to access it remotely


## Cloud Deployment

In order to do a cloud deployment you need:

- Create an account in [DigitalOcean](https://www.digitalocean.com)
- Create an account in [DuckDns](https://www.duckdns.org/)
- Create a personal domain in DuckDns
- Create a personal SSH key in your local computer
- Register your personal SSH key in DigitalOcean

## Manual Cloud Deployment

Follow the next steps to do a manual deployment:

- Create an droplet in DigitalOcean following the requeriments and configure it with your personal RSA Key
- Update DigitalOcean Maniche's IP in the DuckDNS's domain (In my case I have created a domain named `nosql` so the full url will be: `nosql.duckdns.org`)
- Check you can access to the remote machine with `ssh root@nosql.duckdns.org` from a terminal in you local machine
- Execute the following script to setup the box: `ssh root@nosql.duckdns.org "git clone https://github.com/dvillaj/NoSQL-Services.git /opt/deploy && /opt/deploy/install.sh`
- Execute the following script to secure the box: `ssh root@nosql.duckdns.org /opt/deploy/securebox.sh` (a firewall is installed and the only port allowed is the SSH Port)

## Automatic deployment

This repo contains a GitHub action that follows the manual steps automatically. To use this automatic deployment you need to have an account at [GitHub](https://github.com/) and fork this repo

To configure this action do before executing in

- Generate a new Token (API menu) in DigitalOcean and copy it
- Copy the DuckDNS's token from DuckDns's main page. No token generation is needed.
- Add a new repository secret named `DIGITALOCEAN_ACCESS_TOKEN` with the token from DigitalOcean
- Add a new repository secret named `DUCKDNS_TOKEN` with the token from DuckDns
- Edit `.github\workflows\deploy-digitalocean.yml` file to set `DUCKDNS_DOMAIN` variable with the name of your personal DuckDNS's domain.

This action will do:

- Check if Droplet exists previosly (It will not be created twice)
- Create a new 2 GB RAM droplet with Ubuntu 20.04. This droplet can be power up later on DigitalOcean dashboard.
- Configure the access to the remote machine with your personal SSH key
- Execute the setup procedure in the remote machine
- Secure the remote machine disabling all ports exect 22 (SSH Port)
- Update DuckDNS domain with the Droplet IP

This action have to be trigger manually

NOTE: Execute the `Destroy to DigitalOcean Infrastructure` Github's action to destroy the NoSql droplet on DigitalOcean and save money (You will have to do this if you want to execute this action a second time!)


## Access to the services from local

We will access all the services from local using a SSH Tunnelling. Open a terminal in your local machine and execute the following script:

```
ssh -N -L 8001:127.0.0.1:8001 \
             -L 3100:127.0.0.1:3100 \
             -L 27017:127.0.0.1:27017 \
             -L 7474:127.0.0.1:7474 \
             -L 5050:127.0.0.1:5050 \
             -L 8098:127.0.0.1:8098 \
             -L 8082:127.0.0.1:8082 \
             -L 7687:127.0.0.1:7687 \
             -L 61208:127.0.0.1:61208 \
             -L 9000:127.0.0.1:9000 \
            learner@nosql.duckdns.org
```

## TroubleShotting


- Check the jupyterlab service 

```
sudo systemctl status jupyter
```

- Check de Jupyter logs 


```
sudo journalctl -f -u jupyter

```

- Restart the machine

```
sudo restart
```


# Services

## Dependencies 

- [Postgres Docker Compose](https://github.com/dvillaj/compose-postgres)
- [Cassandra Docker Compose](https://github.com/dvillaj/compose-cassandra)
- [MongoDb Docker Compose](https://github.com/dvillaj/compose-mongodb)
- [Neo4j Docker Compose](https://github.com/dvillaj/compose-neo4j)
- [Riak Docker Compose](https://github.com/dvillaj/compose-riak)
- [Riak Docker Image](https://github.com/dvillaj/docker-riak)
- [Cql Python package](https://github.com/dvillaj/ipython-cql.git)
- [Portainer Docker Compose](https://github.com/dvillaj/compose-portainer)

## Jupyter Lab

http://localhost:8001


## Postgres

### Up

```
postgres up -d
```

### Down

```
postgres down
```

### pgAdmin 4

http://localhost:5050

User: `pgadmin4@pgadmin.org`  
Password: `admin`

To connect with the postgres server create a new Server Connection using the following parameters:

```
General/Name: postgres
Connection/Host: postgres
Connection/Username: postgres
Connection/Password: postgres
```

## Riak


### Coordinator / Up

```
riak up -d coordinator
```

### Scale the Cluster (4 members)

```
riak up -d --scale member=4
```

### Down

```
riak down
```


### Admin Riak

http://localhost:8098/admin/



## Cassandra


### Up

```
cassandra up -d
```

### Down

```
cassandra down
```

## MongoDb

Download latest version of [Robo 3T](https://robomongo.org/) and connect to Mongo: `localhost:27017`

### Up

```
mongo up -d
```

### Down

```
mongo down
```

### Mongo Client

http://localhost:3100/


## Neo4j

http://localhost:7474

### Up

```
neo4j up -d
```

### Down

```
neo4j down
```


## Glances

http://localhost:61208


## Portainer

### Up

```
portainer up -d
```

### Down

```
portainer down
```

### Web

http://localhost:9000

User: `admin`  
Password: `password`