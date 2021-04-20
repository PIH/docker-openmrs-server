## isanteplus-server

This repository is responsible for building the "isanteplus/isanteplus-server" Docker image.

### Usage

```sh
docker-compose build --no-cache isanteplus
docker tag <image hash> ghcr.io/isanteplus/isanteplus:<version>
docker tag <image hash> ghcr.io/isanteplus/isanteplus:latest
docker push ghcr.io/isanteplus/isanteplus:latest
docker push ghcr.io/isanteplus/isanteplus:<version>
```

### Tags

Typically branches will represent different server versions.  For example, openmrs-server images for 1.x require
Tomcat 7 and Java 7.  Images that support later OpenMRS versions require Java 8.

This repository will automatically build and push new docker images for all pushed commits and tags as follows:

#### latest

Every commit to master will result in a new tag pushed to DockerHub named "latest"

#### tags

Any time a tag is pushed to github, this will result in a new tag pushed to Dockerhub with the same name

#### branches

Any time a commit is pushed to a non-master branch, a new tag is pushed to Dockerhub with this branch name
