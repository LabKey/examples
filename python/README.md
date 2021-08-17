examples/python
==========

This repository contains scripts and tools which can be used to manage and/or work with data stored in a [LabKey Server](https://www.labkey.org/). 

The scripts and tools that you find here are either in development or have not yet been merged into the LabKey Server [subversion repository](https://www.labkey.org/wiki/home/Documentation/page.view?name=svn) ([more information](https://www.labkey.org/wiki/home/Documentation/page.view?name=openSourceProject))


## Python Scripts 
_Located in the [/python](/LabKey/samples/tree/master/python) folder_

The [LabKey Server Python API](https://www.labkey.org/wiki/home/Documentation/page.view?name=python) provides ways for you to access the data in your LabKey Server programmatically with Python. The LabKey Server Python API does not cover all the functionality of the LabKey Server. These scripts will provide examples for working the LabKey Server Python API and sample scripts for interacting with your LabKey Server in ways not currently covered by the API.

* **upload_file.py**: Use this script to upload a file to your LabKey Server using WEBDAV.
    * Before using the script, goto the Variables section of the script and change the URL, Project and Folder Path to point to your LabKey Server. 
    * Requires the [Poster](https://pypi.python.org/pypi/poster/) package  
    * This script is not officially supported by LabKey.
* **download_study_archive**: Use this script to create a Study Archive and download the resulting archive to your computer.
    * Before using the script, goto the Variables section of the script and change the URL, Project and Folder Path to point to your LabKey Server.
    * Requires the [Poster](https://pypi.python.org/pypi/poster/) package  
    * This script is not officially supported by LabKey.



## Support 

If you need support using these scripts/tools or for the LabKey Server in general, please post message to [LabKey Server Community Forum](https://www.labkey.org/project/home/Server/Forum/begin.view?). Or send me a message on [twitter](https://twitter.com/bdconnolly)([@bdconnolly](https://twitter.com/bdconnolly)).



