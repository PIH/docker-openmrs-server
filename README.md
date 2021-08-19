# iSantePlus Docker Image

[![Build and Deploy](https://github.com/IsantePlus/docker-isanteplus-server/actions/workflows/build-and-deploy.yml/badge.svg)](https://github.com/IsantePlus/docker-isanteplus-server/actions/workflows/build-and-deploy.yml)

This repository is responsible for building the "ghcr.io/isanteplus/isanteplus" Docker image and the isanteplus mysql database image ghcr.io/isanteplus/isanteplus-mysql.

## Usage

### Build and Publish iSantePlus Image
```sh
docker-compose build --no-cache isanteplus
docker tag <image hash> ghcr.io/isanteplus/isanteplus:<version>
docker tag <image hash> ghcr.io/isanteplus/isanteplus:latest
docker push ghcr.io/isanteplus/isanteplus:latest
docker push ghcr.io/isanteplus/isanteplus:<version>
```

### Use Published Image - Docker Compose

`docker-compose.yml`
```json
isanteplus-demo:
    container_name: isanteplus-demo
    hostname: isanteplus-demo
    image: ghcr.io/isanteplus/isanteplus:latest
    restart: unless-stopped
    env_file:
        - ./openmrs/isanteplus_demo/openmrs-server.env
    volumes:
      - openmrs-data:/openmrs/data
    networks:
      - sedish
```

`openmrs-server.env`
```
OMRS_JAVA_MEMORY_OPTS=-Xmx2048m -Xms1024m -XX:NewSize=128m
OMRS_CONFIG_CONNECTION_SERVER=
OMRS_CONFIG_CREATE_DATABASE_USER=false
OMRS_CONFIG_CREATE_TABLES=true
OMRS_CONFIG_ADD_DEMO_DATA=false
OMRS_CONFIG_CONNECTION_URL=
OMRS_CONFIG_HAS_CURRENT_OPENMRS_DATABASE=true
OMRS_JAVA_SERVER_OPTS=-Dfile.encoding=UTF-8 -server -Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Djava.awt.headlesslib=true
OMRS_CONFIG_CONNECTION_USERNAME=
OMRS_CONFIG_CONNECTION_PASSWORD=
```
