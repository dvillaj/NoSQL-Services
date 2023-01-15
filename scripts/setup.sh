#!/bin/bash

# Clone Main Repo
rm -rf ~/notebooks/Taller_BBDD
git clone https://github.com/dvillaj/Taller_BBDD.git ~/notebooks/Taller_BBDD

# Clone Docker Compose Repos
rm -rf /opt/compose/compose*

git clone https://github.com/dvillaj/compose-postgres.git /opt/compose/compose-postgres 
git clone https://github.com/dvillaj/compose-riak.git /opt/compose/compose-riak
git clone https://github.com/dvillaj/compose-cassandra /opt/compose/compose-cassandra
git clone https://github.com/dvillaj/compose-mongodb.git /opt/compose/compose-mongodb
git clone https://github.com/dvillaj/compose-neo4j /opt/compose/compose-neo4j
git clone https://github.com/dvillaj/compose-portainer /opt/compose/compose-portainer

# Kill live containers
if [ $(docker ps -q | wc -l ) -gt 0 ]; then
    echo "Killing live containers"
    docker ps -q | xargs docker stop
fi

# Remove containers
if [ $(docker ps -a -q | wc -l ) -gt 0 ]; then
    echo "Removing containers"
    docker ps -a -q | xargs docker rm
fi

# Remove volumnes
if [ $(docker volume ls -q | wc -l ) -gt 0 ]; then
    echo "Removing volumes"
    docker volume ls -q | xargs docker volume rm
fi

# Pull Images
docker-compose -f /opt/compose/compose-postgres/docker-compose.yml pull
docker-compose -f /opt/compose/compose-riak/docker-compose.yml pull
docker-compose -f /opt/compose/compose-cassandra/docker-compose.yml pull
docker-compose -f /opt/compose/compose-mongodb/docker-compose.yml pull
docker-compose -f /opt/compose/compose-neo4j/docker-compose.yml pull
docker-compose -f /opt/compose/compose-portainer/docker-compose.yml pull