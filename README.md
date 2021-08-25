examples
==========

This repository contains scripts and tools which can be used to manage and/or work with data stored in a [LabKey Server](https://www.labkey.org/). 

The scripts and tools that you find here are either in development or have not yet been merged into the LabKey Server [subversion repository](https://www.labkey.org/wiki/home/Documentation/page.view?name=svn) ([more information](https://www.labkey.org/wiki/home/Documentation/page.view?name=openSourceProject))

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

* **install_labkey_amzn2.sh**:  Sample Amazon Linux Install script - Use this script to aid in installing LabKey on Amazon Linux 2.  
    * This script is not officially supported by LabKey.
* **install_labkey_centos7.sh**:  Sample CentOS 7 Linux Install script - Use this script to aid in installing LabKey on CentOS 7 Linux.
    * This script is not officially supported by LabKey.
* **install-windows-manual.bat**: Use script to install the LabKey Server binaries on Windows. This should only be used if you are performing at [manual installation](https://www.labkey.org/wiki/home/Documentation/page.view?name=manualInstall).
    *  This should only be used if you are performing at [manual installation](https://www.labkey.org/wiki/home/Documentation/page.view?name=manualInstall) on a Windows server.
    * This script is not officially supported by LabKey.
* **upgrade-windows-manual.bat**:  Use script to upgrade a LabKey Server running on Windows, which was manually installed. 
    * [Instruction](https://www.labkey.org/announcements/home/Server/Administration/thread.view?rowId=4842)
    * Do not use this script if you installed your LabKey Server using the [Windows Installer](https://www.labkey.org/wiki/home/Documentation/page.view?name=configWindows). Please use the Windows Installer to upgrade your server
    * This script is not officially supported by LabKey, but it is used by a number of labs and institutions running LabKey Server on Windows. 
    * If you have questions or need support, please post a message on the [LabKey Server Community Forum](https://www.labkey.org/project/home/Server/Forum/begin.view?).
* **upgrade-remote-pipeline.sh**: Use script to upgrade a LabKey Remote Pipeline Server running on \*nix operating system.
    * This script is not officially supported by LabKey and there is currently no documentation for it. However, I regularly use a modified version of this on my test servers. 
    * If you have questions or need support, please post a message on the [LabKey Server Community Forum](https://www.labkey.org/project/home/Server/Forum/begin.view?).
* **upgrade-remote-pipeline.bat**: Use script to upgrade a LabKey Remote Pipeline Server running on Windows that was installed manually.
    * This script is not officially supported by LabKey and there is currently no documentation for it. However, I regularly use a modified version of this on my test servers.
    * Do not use this script if you installed your LabKey Remote Pipeline Server using the [Windows Installer](https://www.labkey.org/wiki/home/Documentation/page.view?name=configWindows). Please use the Windows Installer to upgrade your server.
    * If you have questions or need support, please post a message on the [LabKey Server Community Forum](https://www.labkey.org/project/home/Server/Forum/begin.view?).
* **labkey-database-backup-sample-script.bat**: This script can be used to perform a nightly backup (using pg_dump) of databases on a PostgreSQL server instance.
    * This script is not officially supported by LabKey and there is currently no documentation for it.
    * See [blog entry](http://fourproc.com/2013/05/02/using-labkey-s-sample-backup-script-to-backup-your-postgresql-database.html) for more information on using the script.


### Docker
_Located in the [/docker](./docker) folder_

* **labkey-standalone**: Dockerfile and other source files needed for building a Docker image that runs LabKey Server. 
    * See the [README](./docker/labkey-standalone/README.md) file for information on building your own image or 
    * See [bconn/labkey-standalone](https://registry.hub.docker.com/u/bconn/labkey-standalone/) on DockerHub.
    * This script is not officially supported by LabKey.

### Ontology
_Located in the [/ontology](./ontology) folder_

A set of python scripts which can help generate an ontology archive that can then be loaded into LabKey.
The scripts are designed to accept OWL NCI, and GO files, but support is not universal for all files of these types.

## Support 

If you need support using these scripts/tools or for the LabKey Server in general, please contact your Account Manager or post a message to the LabKey Server Community Forum.
