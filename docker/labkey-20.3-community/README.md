samples/docker/labkey-20.3-community
==========

This folder contains a sample docker-compose file and sample Docker configurations to stand up an instance of LabKey Server Community edition for testing.

### IMPORTANT: Not Recommended for Production use
 This image is meant for trying out LabKey Server and not meant for running LabKey as a production service.
#### Technology configuration:
* LabKey Server 20.3.2 
* Tomcat 9
* OpenJDK-14
* PostgreSQL 11


## Usage 

### Recommended configuration steps

1. Clone this repo
1. Edit the labkey/config/labkey.xml and choose your own settings for the following
    1. jdbc (DB) username and password
    1. MasterEncryptionKey password 
    1. SMTP settings
1. Edit the postgres/fixtures/create_fixtures.sql file
    1.  DB username and password should match those configued in labkey/config/labkey.xml 


### Running LabKey Server 

To build and run the LabKey service  

    sudo docker-compose up -d --build

After few seconds, open [http://localhost:8080/labkey](http://localhost:8080/labkey) to see the LabKey Server initialization page.

To stop the LabKey service    

    sudo docker-compose down

### Persisted Volumes
The example configuration will create persistent volumes in the shared_volumes folder for the following:
1. `shared_volumes/logs/labkey` - labkey tomcat logs
1. `shared_volumes/labkey-files` - labkey files directory
1. `shared_volumes/postgres11` - postgres data directory included database files



