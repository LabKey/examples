examples/ops
==========

This repository contains scripts and tools which can be used to manage and/or work with data stored in a [LabKey Server](https://www.labkey.org/). 

The scripts and tools that you find here are either in development or have not yet been merged into the LabKey Server [subversion repository](https://www.labkey.org/wiki/home/Documentation/page.view?name=svn) ([more information](https://www.labkey.org/wiki/home/Documentation/page.view?name=openSourceProject))


## Installation and Upgrade 

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


## Configuration File Examples
_Located in the [/config-examples](/LabKey/samples/tree/master/config-examples) folder_

This folder contains examples of configuration files for Tomcat, PostgreSQL and LabKey Server that can be customized or used in your installation of LabKey Server.

* **server.xml**: Example `server.xml` configuration file for Tomcat7. This configuration file 
    * Enables the HTTP connector to listen on port `TCP/80`
    * Enables [access logging](http://tomcat.apache.org/tomcat-7.0-doc/config/valve.html#Access_Logging) using a custom pattern that is described at [http://www.fourproc.com/2010/06/02/improved-access-logging-format-for-labkey-server-.html](http://www.fourproc.com/2010/06/02/improved-access-logging-format-for-labkey-server-.html).
* **server-SSL.xml**: Example `server.xml` configuration file for Tomcat7. This configuration file 
    * Enables the HTTP connector to listen on port `TCP/80`
    * Enables the HTTPS connector to listen on port `TCP/443`
    * HTTPS connector configuration protects against [BEAST](http://blog.zoller.lu/2011/09/beast-summary-tls-cbc-countermeasures.html) and [POODLE](https://www.imperialviolet.org/2014/10/14/poodle.html) attacks.
    * Enables [access logging](http://tomcat.apache.org/tomcat-7.0-doc/config/valve.html#Access_Logging) using a custom pattern that is described at [http://www.fourproc.com/2010/06/02/improved-access-logging-format-for-labkey-server-.html](http://www.fourproc.com/2010/06/02/improved-access-logging-format-for-labkey-server-.html).


## Support 

If you need support using these scripts/tools or for the LabKey Server in general, please post message to [LabKey Server Community Forum](https://www.labkey.org/project/home/Server/Forum/begin.view?). Or send me a message on [twitter](https://twitter.com/bdconnolly)([@bdconnolly](https://twitter.com/bdconnolly)).

