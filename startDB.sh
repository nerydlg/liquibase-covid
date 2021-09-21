#!/bin/bash

docker run -it --rm --name postgres -e POSTGRES_PASSWORD=admin01 -e PGDATA=/var/lib/postgresql/data/pgdata -v ${PWD}/data:/var/lib/postgresql/data -p 5432:5432 -d postgres 
