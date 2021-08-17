# Liquibase covid

This repo contains database structure for the covid database

## How to use

### Setup
1. Install Java, if you don't know how, follow steps in this [link](https://www.java.com/en/download/help/windows_manual_download.html).
2. Install Maven, if you don't know how, follow steps in this [link](https://maven.apache.org/install.html). 
3. Change values for `user`, `url` and `password` in the `src/main/resources/liquibase.properties`.
4. Install docker, if you don't know how, follow steps in this [link](https://docs.docker.com/get-docker/).
5. Execute the bash file called: `startDB.sh`, _NOTE_: this only works in linux but you can copy the docker command it should work in windows.
6.  create the database manually.
    
### DB Installation 
Execute the following command:
```shell
mvn liquibase:update
```
