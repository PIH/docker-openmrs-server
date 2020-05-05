# openmrs-server

This repository is responsible for building the "openmrs-server" Docker image.

## Tags

Typically branches will represent different server versions.  For example, openmrs-server images for 1.x require
Tomcat 7 and Java 7.  Images that support later OpenMRS versions require Java 8.

This repository will automatically build and push new docker images for all pushed commits and tags as follows:

### latest

Every commit to master will result in a new tag pushed to DockerHub named "latest"

### tags

Any time a tag is pushed to github, this will result in a new tag pushed to Dockerhub with the same name

### branches

Any time a commit is pushed to a non-maste rbranch, a new tag is pushed to Dockerhub with this branch name

## Usage

This docker image does not contain any OpenMRS artifacts by default.  It is designed to mount an OpenMRS distribution
into a named volume with a specific directory structure.  Environment variables allow for full configuration of server 
initialization.  The available environment variables and their defaults are viewable [within the Dockerfile](./Dockerfile).
