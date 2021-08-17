examples/docker/labkey-standalone
==========

With the recent release of [kubernetes](https://github.com/GoogleCloudPlatform/kubernetes) from Google and news of [Docker support in Elastic Beanstalk](http://aws.amazon.com/about-aws/whats-new/2014/04/23/aws-elastic-beanstalk-adds-docker-support/), I figured it was finally time to give containers (and Docker ) a try. 

This folder contains the Dockerfile, additional scripts and instructions for building a Docker image which you can use to give LabKey Server a try. An image built with this Dockerfile is available at [bconn/labkey-standalone](https://registry.hub.docker.com/u/bconn/labkey-standalone/) on DockerHub.

**IMPORTANT:** This image was meant for trying out LabKey Server and not meant for running a production server or for storing important biomedical data. 


## Is there an image already built? 

An image built with this Dockerfile is available at [bconn/labkey-standalone](https://registry.hub.docker.com/u/bconn/labkey-standalone/) on DockerHub. This image contains: 

* LabKey Server 14.1 
* Tomcat 7
* Oracle Java 7
* PostgreSQL 9.3 



## Usage 

### Create the image
To create the image you will need do the following:

1. Download the latest version of [Oracle JAVA 7 ServerJRE](http://www.oracle.com/technetwork/java/javase/downloads/server-jre7-downloads-1931105.html) to `./labkey/src` directory 
1. Download the latest version of [Tomcat 7](http://tomcat.apache.org/download-70.cgi) binary distribution to `./tomcat`
    * Use the _Core tar.gz_ download
1. Download the latest version of [LabKey Server](http://labkey.com/download-labkey-server) to `./labkey/src` directory
    * Use the _Binaries for Manual Linux/Mac/Unix Installation_ link
1. Update the `Dockerfile` and change the names in the file to match the ones you downloaded above.
1. Build the image 
        
        sudo docker build -t bconn/labkey-standalone .


### Running LabKey Server Standalone in a container

To run the image 

    sudo docker run --name labkey-standalone -d -p 8080:8080 bconn/labkey-standalone


After few seconds, open [http://<host>:8080](http://<host>:8080) to see the LabKey Server initialization page.




