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


if [ -f ~/notebooks/.install ]; then
    docker pull postgres:12.2
    docker pull dpage/pgadmin4:4.20
    docker pull dvillaj/riak
    docker pull cassandra:3.11
    docker pull mongo:5.0.3
    docker pull neo4j:3.5.11
    docker pull huggingface/mongoku:1.3.0  
    docker pull portainer/portainer-ce:2.9.2-alpine
fi