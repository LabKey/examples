samples/ops/config-examples
==========

This repository contains scripts and tools which can be used to manage and/or work with data stored in a [LabKey Server](https://www.labkey.org/). 

The scripts and tools that you find here are either in development or have not yet been merged into the LabKey Server [subversion repository](https://www.labkey.org/wiki/home/Documentation/page.view?name=svn) ([more information](https://www.labkey.org/wiki/home/Documentation/page.view?name=openSourceProject))


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

