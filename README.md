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

The deployment may be manual or automaic ...

## Manual Deployment

A Ubuntu box has to be previously created before you can execute the set up procedure.

The Ubuntu box's requirements are:

 - 20.04 Ubuntu Server with at least 2 Gb of Memory 
 - Remote access to the machine through a RSA SSH key
 - RSA SSH key available in your local machine

There are two possibilities:

 - A box deployed in your local machine with Vagrant & VirtualBox:  https://github.com/dvillaj/NoSQL-box
 - A box deployed with a Cloud Provider like [DigitalOcean](https://www.digitalocean.com) or similar (Azure, Google, AWS, etc.) to access it remotely


### Access to the Box

Create a domain in [DuckDns](https://www.duckdns.org/) and update it with the real machine's IP DuckDNS.

In my case I have created a domain named `nosql` so the full url will be: `nosql.duckdns.org`

```

ssh root@nosql.duckdns.org
```

### Setup the Box

Execute the following script to setup the box:

```
ssh root@nosql.duckdns.org "git clone https://github.com/dvillaj/NoSQL-Services.git /opt/deploy && /opt/deploy/install.sh"
```

### Secure the Box 

This procedure is recommended if the box is deployed online and must to be executed after all the services has been installed.


Execute the following script:

```
ssh root@nosql.duckdns.org /opt/deploy/securebox.sh
```

After executing this script the SSH Port (22) will be the only port allowed.


## Access to the services from local

We will access all the services from local using a SSH Tunnelling.

Open a terminal in your local machine and execute the following script:

```
ssh -N -L 8001:127.0.0.1:8001 \
             -L 3100:127.0.0.1:3100 \
             -L 27017:127.0.0.1:27017 \
             -L 7474:127.0.0.1:7474 \
             -L 5050:127.0.0.1:5050 \
             -L 8098:127.0.0.1:8098 \
             -L 8082:127.0.0.1:8082 \
             -L 7687:127.0.0.1:7687 \
             -L 7687:127.0.0.1:61208 \
             -L 7687:127.0.0.1:9000 \
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