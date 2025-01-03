examples
==========

This repository contains scripts and tools which can be used to manage and/or work with data stored in a [LabKey Server](https://www.labkey.org/). 

The scripts and tools that you find here are either in development or have not yet been merged into other LabKey GitHub repos ([more information](https://www.labkey.org/wiki/home/Documentation/page.view?name=openSourceProject))

## Available Scripts and Tools 

### Python Scripts 
_Located in the [/python](./python) folder_

The [LabKey Server Python API](https://www.labkey.org/wiki/home/Documentation/page.view?name=python) provides ways for you to access the data in your LabKey Server programmatically with Python. The LabKey Server Python API does not cover all the functionality of the LabKey Server. These scripts will provide examples for working the LabKey Server Python API and sample scripts for interacting with your LabKey Server in ways not currently covered by the API.

* **upload_file.py**: Use this script to upload a file to your LabKey Server using WEBDAV.
    * Before using the script, goto the Variables section of the script and change the URL, Project and Folder Path to point to your LabKey Server. 
    * Requires the [Poster](https://pypi.python.org/pypi/poster/) package  
    * This script is not officially supported by LabKey.
* **download_study_archive**: Use this script to create a Study Archive and download the resulting archive to your computer.
    * Before using the script, goto the Variables section of the script and change the URL, Project and Folder Path to point to your LabKey Server.
    * Requires the [Poster](https://pypi.python.org/pypi/poster/) package  
    * This script is not officially supported by LabKey.



### Installation and Upgrade
_Located in the [/ops](./ops) folder_

* **labkey-database-backup-sample-script.bat**: This script can be used to perform a nightly backup (using pg_dump) of databases on a PostgreSQL server instance.
    * This script is not officially supported by LabKey and there is currently no documentation for it.
    * See [blog entry](http://fourproc.com/2013/05/02/using-labkey-s-sample-backup-script-to-backup-your-postgresql-database.html) for more information on using the script.


### Ontology
_Located in the [/ontology](./ontology) folder_

A set of python scripts which can help generate an ontology archive that can then be loaded into LabKey.
The scripts are designed to accept OWL NCI, and GO files, but support is not universal for all files of these types.

## Support 

If you need support using these scripts/tools or for the LabKey Server in general, please contact your Account Manager or post a message to the LabKey Server Community Forum.
