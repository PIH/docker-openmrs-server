## openmrs-server

This repository is responsible for building the "partnersinhealth/openmrs-server" Docker image.

### Usage

This docker image does not contain any OpenMRS artifacts by default.  It is designed to mount an OpenMRS distribution
into a named volume with a specific directory structure.  Environment variables allow for full configuration of server 
initialization.  The following steps should be taken to use this image:


#### Create OpenMRS distribution

An OpenMRS distribution should be assembled on the host machine in the following directory structure:

* openmrs_webapps/
  * openmrs.war
* openmrs_modules/
  * moduleid-version.omod
* openmrs_owas/
  * OwaName-version.zip
* openmrs_config/
  * files to be deployed into .OpenMRS/configuration directory for Initializer, etc

#### Specify environment variables within an "env" file

The below is a list of supported enviroment variables, along with their default values if left unspecified:

**Specify JAVA_OPTS**

* OMRS_JAVA_MEMORY_OPTS: ```-Xmx2048m -Xms1024m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:NewSize=128m```
* OMRS_JAVA_SERVER_OPTS: ```-Dfile.encoding=UTF-8 -server -Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Djava.awt.headlesslib=true```

**Set initialization parameters in openmrs-server.properties**

* OMRS_CONFIG_ADD_DEMO_DATA: ```false```
* OMRS_CONFIG_ADMIN_USER_PASSWORD: ```Admin123```
* OMRS_CONFIG_AUTO_UPDATE_DATABASE: ```false```
* OMRS_CONFIG_CONNECTION_DRIVER_CLASS: ```com.mysql.jdbc.Driver```
* OMRS_CONFIG_CONNECTION_USERNAME: ```openmrs```
* OMRS_CONFIG_CONNECTION_PASSWORD: ```openmrs```
* OMRS_CONFIG_CONNECTION_SERVER: ```db```
* OMRS_CONFIG_CONNECTION_PORT: ```3306```
* OMRS_CONFIG_CONNECTION_NAME: ```openmrs```
* OMRS_CONFIG_CONNECTION_ARGS: ```autoReconnect=true&sessionVariables=storage_engine=InnoDB&useUnicode=true&characterEncoding=UTF-8```
* OMRS_CONFIG_CONNECTION_EXTRA_ARGS: ``````
* OMRS_CONFIG_CREATE_DATABASE_USER: ```false```
* OMRS_CONFIG_CREATE_TABLES: ```false```
* OMRS_CONFIG_HAS_CURRENT_OPENMRS_DATABASE: ```true```
* OMRS_CONFIG_INSTALL_METHOD: ```auto```
* OMRS_CONFIG_MODULE_WEB_ADMIN: ```true```

**Enable debugging by specifying port**

* OMRS_DEV_DEBUG_PORT: ```1044```

**Customize OpenMRS Webapp Name**

* OMRS_WEBAPP_NAME: ```openmrs```

#### Start up the container in docker-compose with these values

```yaml
  openmrs-server:
    image: partnersinhealth/openmrs-server:latest
    depends_on:
      - db
    env_file:
        - ./openmrs-server.env
    volumes:
      - ./distribution:/openmrs/distribution
      - openmrs-data:/openmrs/data
    ports:
      - "8080:8080"
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
