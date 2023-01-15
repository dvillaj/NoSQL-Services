#!/bin/bash

rm -rf ~/notebooks/Taller_BBDD
git clone https://github.com/dvillaj/Taller_BBDD.git ~/notebooks/Taller_BBDD

rm -rf /opt/compose/compose*

git clone https://github.com/dvillaj/compose-postgres.git /opt/compose/compose-postgres 
git clone https://github.com/dvillaj/compose-riak.git /opt/compose/compose-riak
git clone https://github.com/dvillaj/compose-cassandra /opt/compose/compose-cassandra
git clone https://github.com/dvillaj/compose-mongodb.git /opt/compose/compose-mongodb
git clone https://github.com/dvillaj/compose-neo4j /opt/compose/compose-neo4j
git clone https://github.com/dvillaj/compose-portainer /opt/compose/compose-portainer


# Kill live containers
if [ -s "$(docker ps -q)" ]; then
    echo "Killing Containers ..."
    docker kill $(docker ps -q)
fi

# Remove containers
if [ -s "$(docker ps -a -q)" ]; then
    echo "Removing Containers ..."
    docker rm -f $(docker ps -a -q)
fi

# Remove volumnes
if [ -s "$(docker volume ls -q)" ]; then
    echo "Removing Volumes ..."
    docker volume rm $(docker volume ls -q)
fi

# Pull Images
docker-compose -f /opt/compose/compose-postgres/docker-compose.yml pull
docker-compose -f /opt/compose/compose-riak/docker-compose.yml pull
docker-compose -f /opt/compose/compose-cassandra/docker-compose.yml pull
docker-compose -f /opt/compose/compose-mongodb/docker-compose.yml pull
docker-compose -f /opt/compose/compose-neo4j/docker-compose.yml pull
docker-compose -f /opt/compose/compose-portainer/docker-compose.yml pull