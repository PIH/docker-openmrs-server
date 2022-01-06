FROM maven:3.6-jdk-8 as download
ARG USERNAME
ARG TOKEN
ARG ISANTEPLUS_VERSION=v2.0.1

RUN apt-get update; \
	apt-get install -y --no-install-recommends \
		rename

WORKDIR /
RUN mkdir -p /root/.m2 \
    && mkdir /root/.m2/repository
COPY ./resources/settings.xml.template .
RUN sed -e "s/\${your-github-username}/$USERNAME/" -e "s/\${your-github-token}/$TOKEN/" settings.xml.template | tee /root/.m2/settings.xml

WORKDIR /root
RUN git clone --depth 1 --branch $ISANTEPLUS_VERSION https://github.com/IsantePlus/openmrs-distro-isanteplus.git
WORKDIR /root/openmrs-distro-isanteplus
RUN mvn clean package -U -B

WORKDIR /root/openmrs/distribution
RUN mkdir openmrs_modules openmrs_webapps

RUN cp -r /root/openmrs-distro-isanteplus/package/target/distro/web/modules/* openmrs_modules
RUN cp -r /root/openmrs-distro-isanteplus/package/target/distro/web/openmrs.war openmrs_webapps/

# TODO: Fix distro package to allow download of published package
# RUN mvn dependency:get -Dartifact=org.openmrs.distro:isanteplus:${ISANTEPLUS_VERSION}:zip -DrepositoryId=github-packages
# RUN mvn dependency:get -Dartifact=org.openmrs.distro:isanteplus:${ISANTEPLUS_VERSION}:war -DrepositoryId=github-packages
# RUN mvn -q dependency:copy -Dartifact=org.openmrs.distro:isanteplus:${ISANTEPLUS_VERSION}:zip -DoutputDirectory=./openmrs_modules
# RUN mvn -q dependency:copy -Dartifact=org.openmrs.distro:isanteplus:${ISANTEPLUS_VERSION}:war -DoutputDirectory=./openmrs_webapps

WORKDIR /root/openmrs/distribution/openmrs_modules

# TODO: Fix artifact names to not have a dash in these two projects
RUN rename 's/m2sys-(.+).omod$/m2sys-biometrics-$1\.omod/' *.omod
RUN rename 's/outgoing-(.+).omod$/outgoing-message-exceptions-$1\.omod/' *.omod
RUN rename 's/xds-(.+).omod$/xds-sender-$1\.omod/' *.omod
RUN rename 's/santedb-(.+).omod$/santedb-mpiclient-$1\.omod/' *.omod

# TODO: remove when addresshierarchy, patientflags, situation is resolved
RUN rm addresshierarchy*
RUN wget https://github.com/IsantePlus/isanteplus_installation/raw/main/modules/addresshierarchy-2.11.0-SNAPSHOT.omod
RUN rm patientflags*
RUN wget https://github.com/IsantePlus/isanteplus_installation/raw/main/modules/patientflags-2.0.0-SNAPSHOT.omod

FROM tomcat:7-jre8 as build

## Take some initial steps to improve overall security, size, and functionality of the container
## This includes updating packages and removing all of the default Tomcat webapps

RUN apt-get update && apt-get install -y \
       zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /usr/local/tomcat/webapps/*

RUN sed -i '/Connector port="8080"/a URIEncoding="UTF-8" relaxedPathChars="[]|" relaxedQueryChars="[]|{}^&#x5c;&#x60;&quot;&lt;&gt;"' /usr/local/tomcat/conf/server.xml

# All environment variables that are available to configure on this container are listed here
# for clarity.  These list the variables supported, and the default values if not overridden

# These environment variables are appended to configure the Tomcat JAVA_OPTS
ENV OMRS_JAVA_MEMORY_OPTS="-Xmx2048m -Xms1024m -XX:NewSize=128m"
ENV OMRS_JAVA_SERVER_OPTS="-Dfile.encoding=UTF-8 -server -Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Djava.awt.headlesslib=true"

# These environment variables are used to create the openmrs-server.properties file, which controls how OpenMRS initializes
ENV OMRS_CONFIG_ADD_DEMO_DATA="false"
ENV OMRS_CONFIG_ADMIN_USER_PASSWORD="Admin123"
ENV OMRS_CONFIG_AUTO_UPDATE_DATABASE="true"
# valid values are mysql and postgres
ENV OMRS_CONFIG_CONNECTION_TYPE="mysql"
ENV OMRS_CONFIG_CONNECTION_USERNAME="mysqluser"
ENV OMRS_CONFIG_CONNECTION_PASSWORD="mysqlpw"
ENV OMRS_CONFIG_CONNECTION_SERVER="localhost"
ENV OMRS_CONFIG_CONNECTION_NAME="openmrs"
ENV OMRS_CONFIG_CREATE_DATABASE_USER="false"
ENV OMRS_CONFIG_CREATE_TABLES="false"
ENV OMRS_CONFIG_HAS_CURRENT_OPENMRS_DATABASE="true"
ENV OMRS_CONFIG_INSTALL_METHOD="auto"
ENV OMRS_CONFIG_MODULE_WEB_ADMIN="true"

# These environment variables are meant to enable developer settings
ENV OMRS_DEV_DEBUG_PORT="1044"

# Additional environment variables as needed.  This should match the name of the distribution supplied OpenMRS war file
ENV OMRS_WEBAPP_NAME="openmrs"

# Set up volumes.
# /openmrs/data represents the data persisted inside the container to the filesystem for OpenMRS
VOLUME ["/openmrs/data"]
COPY --from=download /root /

VOLUME /openmrs/distribution/openmrs_modules

VOLUME /custom_modules

# Copy in the start-up scripts
COPY ./resources/wait-for-it.sh /usr/local/tomcat/wait-for-it.sh
COPY ./resources/startup.sh /usr/local/tomcat/startup.sh
RUN chmod +x /usr/local/tomcat/wait-for-it.sh
RUN chmod +x /usr/local/tomcat/startup.sh

# Add Dockerfile and commit info for documentation
ADD ./Dockerfile /openmrs/docker

EXPOSE 8080

ENTRYPOINT ls /custom_modules && /usr/local/tomcat/startup.sh