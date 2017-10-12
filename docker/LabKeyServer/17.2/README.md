# samples/docker/LabKeyServer/17.2

This folder contains a Dockerfile, scripts and instructions for building a Docker image can be used to try out LabKey Server. Using this Dockerfile will result in a single container which runs the services required(PostgreSQL and Tomcat) to run a LabKey Server application.

This Dockerfile will install following software in the container

* Base: `Ubuntu Core 16.04`
* PostgreSQL: `9.5.5`
* Tomcat: `8.0.38`
* Java: `1.8u112`
* LabKey Server: `Labkey17.2-52553-community-bin`


This Dockerfile also creates three VOLUMES. These volumes will hold all persistent data that will be created while using LabKey Server.

* Sitewide FileRoot: `/labkey/labkey/files`
* LabKey Server log files: `/labkey/apps/tomcat/logs`
* PostgreSQL Data Directory: `/labkey/apps/postgresql/data`


**IMPORTANT:** This image was meant for trying out LabKey Server and not meant for running a production server or for storing important biomedical data.




## Usage

How to build an image for this dockerfile

    cd samples/docker/labkeyserver-single
    docker build -t labkeyserver:17.2 .

This command will take a couple of minutes to complete.


How to run the container from this image

    docker run -p 8080:8080 --name LabKeyServer_17.2 labkeyserver:17.2


Once the container is started, you should be able to access the LabKey Server by opening your browser and going to either

* [http://<container-ip>:8080](http://<container-ip>:8080) or
* [http://<dockerhost>:8080](http://<dockerhost>:8080)


**RECOMMENDED**: If you would like change the PostgreSQL password and Master Encryption Key used by the LabKey Server application these can be specified as ENV variables when you execute `docker run ....`. To do this you would first create an ENV file

    vi LabKeyServer_17.2_env-file
    (add)
    PG_PASSWORD=new-password
    LABKEY_ENCRYPTION_KEY=verylongstringtobeusedForEncryptingPropertyStore122222

Now you can create a new container, which uses these values by running

    docker run --env-file ./LabKeyServer_17.2_env-file -p 8080:8080 --name LabKeyServer_17.2 labkeyserver:17.2


### Usage Notes

* Add the `--rm` command line option to the `docker run` if you would like the container removed when it exits (please note, this will also remove the container volumes contain PostgreSQL database and Sitewide FileRoot)
* This Dockerfile will create 3 volumes, when the removing the container use the `-v` option to remove the data in these volumes also. See [here](https://docs.docker.com/engine/tutorials/dockervolumes/#removing-volumes) for more information.




## Start and Stop the Container

If you want to stop the container, you can run

    docker stop LabKeyServer_17.2

This will stop Tomcat, PostgreSQL and XVFB servers and then stop the container

To restart the container, run

    docker start LabKeyServer_17.2

This will execute the ENTRYPOINT and CMD statements in the dockerfile again.

### Usage Notes

* When using this `--rm` command line option, stopping the container will result in the container and all volumes being deleted




## Backup Data and Files used by LabKey Server application

There are number of options for how the database and files in the running container can be backed up. One option is described below.

### Backup the LabKey Server Database
For this you will be need to execute two commands. The first command use `docker exec` to execute `pgdump` in the `LabKeyServer_17.2` container. The second will start a new container which will have access to all volumes mounted on the `LabKeyServer_17.2` container and copy the backup file to the local directory

    docker exec -u postgres -t LabKeyServer_17.2 bash -c "/labkey/apps/postgresql/bin/pg_dump --format=c --compress=9 -f /labkey/apps/postgresql/data/backup/postgres_labkey_$(date +%Y%m%d).bak labkey"

The second command will start a new container which will have access to all volumes mounted on the `LabKeyServer_17.2` container and copy the backup file to the local directory

    docker run --rm --volumes-from LabKeyServer_17.2 -v $(pwd):/backup ubuntu bash -c "cp /labkey/apps/postgresql/data/backup/postgres_labkey_$(date +%Y%m%d).bak /backup/"


### Backup the files in the Sitewide FileRoot
For this you will start a new container which will have access to all volumes mounted on the `LabKeyServer_17.2` container and use the `tar` command to backup all the files and directories.

    docker run --rm --volumes-from LabKeyServer_17.2 -v $(pwd):/backup ubuntu bash -c "tar czf /backup/fileroot_$(date +%Y%m%d).tar.gz /labkey/labkey/files "


### Backup the LabKey Server log files
For this you will start a new container which will have access to all volumes mounted on the `LabKeyServer_17.2` container and use the `tar` command to backup all the files and directories.

    docker run --rm --volumes-from LabKeyServer_17.2 -v $(pwd):/backup ubuntu bash -c "tar czf /backup/labkey_logs_$(date +%Y%m%d).tar.gz /labkey/apps/tomcat/logs "


## Use a different version of LabKey Server

If you would like to create a Docker image and container which runs a different version of LabKey Server you can run a command similar to

    cd samples/docker/labkeyserver-single
    docker build --build-arg LABKEY_DIST=17.2-49086.73-community -t labkeyserver:17.2-49086 .

Where `17.2-49086.73-community` is the new build version that you would like to use in the container.




## Use SSL in the Container
If you would like to use SSL when connecting to your LabKey Server you can use the `Dockerfile-ssl` dockerfile. To use this file, you will need to

1. Create a Java Keystore
2. Place the keystore file in `./tomcat` directory and name it `keystore.tomcat`
3. When starting the image, specify the keystore passphrase using the `KEYSTORE_PASSPHRASE` ENV variable

If you do not have a Java keystore file already created, you can use the command below to create a new keystore which contains a self-signed certificate.

    /labkey/apps/java/bin/keytool -genkey -dname "CN=dockerhost, OU=LabKey, O=LabKey, L=Seattle, S=Washington, C=US" -alias tomcat -keystore ./tomcat/keystore.tomcat -storepass changeitnow -keypass changeitnow -keyalg RSA -keysize 2048 -validity 730 -storetype pkcs12

    * Change the storepass and keypass variables to a different value


Now that this is created, you can start a new container by running

    docker build -t labkeyserver-ssl:17.2 -f Dockerfile-ssl .

This command will take a couple of minutes to complete.


How to run the container from this image

    docker run -p 8080:8080 -p 8443:8443 --env KEYSTORE_PASSPHRASE=changeitnow --name LabKeyServerSSL_17.2 labkeyserver-ssl:17.2




## Additional Commands that might be of interest

### Removing Container Volumes

To remove a container and it's volumes, you can run

    docker rm -v CONTAINERNAME

To view the volumes that were associated with containers that have been deleted run

    docker volume ls -f dangling=true

To remove volumes that were associated with containers that have been deleted run

    docker volume rm $(docker volume ls -qf dangling=true)
