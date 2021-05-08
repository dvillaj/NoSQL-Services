# NoSQL-Services

This repo contains all the scripts needed to set up a Ubuntu box with several NoSQL Databases and a Jupyter environment to play with them

## Installed Services

- Postgres
- Riak
- Cassandra
- Mongodb
- Neo4j
- JupyterLab

Most of the services are powered by Docker and Docker Compose.

## Requirements

A Ubuntu box has to be previously created you can execute the set up procedure.

The Ubuntu box's requirements are:

 - 20.04 Ubuntu Server with at least 2 Gb of Memory 
 - Remote access to the machine through SSH keys
 - RSA SSH key available in your local machine

There are two possibilities to accomplish this:

 - A box deployed in your local machine with Vagrant & VirtualBox:  https://github.com/dvillaj/NoSQL-box
 - A box deployed with a Cloud Provider like DigitalOcean, Azure, AWS, etc ... 

SSH Key:

To create a SSH Key in your local machine of the following link:

https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-2

NOTE: Steps 1 and 2 only

## Example

This following video is an example of how to create a Ubuntu box in DigitalOcean cloud provider and setup the remote machine to access all the NoSql services

https://youtu.be/obbbQvBMTsM


## Access to the Box

Replace `<IP>` with the real Machine's IP ...

```
MACHINE_IP=<IP>

ssh root@$MACHINE_IP
```

## Setup the Box

Execute the following script to setup the box:

```
ssh root@$MACHINE_IP "git clone https://github.com/dvillaj/NoSQL-Deployer.git /opt/deploy && /opt/deploy/install.sh"
```

## Secure the Box 

This procedure is recommended if the box is deployed online and have to be executed after all the services has been installed.


Execute the following script:

```
ssh root@$MACHINE_IP /opt/deploy/securebox.sh
```

After executing this script the SSH Port (22) is the only port allowed.


## Access to the services

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
            learner@$MACHINE_IP
```

## TroubleShotting


- Check the jupyterlab service 

```
sudo systemctl status jupyter
```

- Check de Jypyer logs 


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
- 

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
