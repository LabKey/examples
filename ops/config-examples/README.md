samples/ops/config-examples
==========

This repository contains scripts and tools which can be used to manage and/or work with data stored in a [LabKey Server](https://www.labkey.org/).

The scripts and tools that you find here are either in development or have not yet been merged into the LabKey Server [subversion repository](https://www.labkey.org/wiki/home/Documentation/page.view?name=svn) ([more information](https://www.labkey.org/wiki/home/Documentation/page.view?name=openSourceProject))


## Configuration File Examples
_Located in the [/config-examples](/LabKey/samples/tree/master/config-examples) folder_

This folder contains examples of configuration files for Tomcat, PostgreSQL and LabKey Server that can be customized or used in your installation of LabKey Server.

Please note that the [Apache Tomcat team ended support for Apache Tomcat 8.0.x on 30 June 2018](https://tomcat.apache.org/tomcat-80-eol.html). As such, we also no longer support Tomcat 8.0 installations with LabKey and we recommend you upgrade to the latest version of Tomcat that is available.

* **server.xml**: Example `server.xml` configuration file for Tomcat8. This configuration file
    * Enables the HTTP connector to listen on port `TCP/80`
    * Enables [access logging](http://tomcat.apache.org/tomcat-8.5-doc/config/valve.html#Access_Logging) using a custom pattern that is described on the [LabKey Community Forums](https://www.labkey.org/home/Support/Inactive%20Forums/Administration%20Forum%20(Inactive)/announcements-thread.view?rowId=4104).
    * Utilizes the [org.apache.coyote.http11.Http11NioProtocol](http://tomcat.apache.org/tomcat-8.5-doc/api/org/apache/coyote/http11/Http11Protocol.html) protocol. The org.apache.coyote.http11.Http11Protocol class has been deprecated in Tomcat 9.0, but the Nio protocol works in both Tomcat 8.5 and Tomcat 9.0.
* **server-SSL.xml**: Example `server.xml` configuration file for Tomcat8. This configuration file
    * Enables the HTTP connector to listen on port `TCP/80`
    * Enables the HTTPS connector to listen on port `TCP/443`
    * HTTPS connector configuration protects against [BEAST](http://blog.zoller.lu/2011/09/beast-summary-tls-cbc-countermeasures.html) and [POODLE](https://www.imperialviolet.org/2014/10/14/poodle.html) attacks.
    * Enables [access logging](http://tomcat.apache.org/tomcat-8.5-doc/config/valve.html#Access_Logging) using a custom pattern that is described on the [LabKey Community Forums](https://www.labkey.org/home/Support/Inactive%20Forums/Administration%20Forum%20(Inactive)/announcements-thread.view?rowId=4104).
    * Utilizes the [org.apache.coyote.http11.Http11NioProtocol](http://tomcat.apache.org/tomcat-8.5-doc/api/org/apache/coyote/http11/Http11Protocol.html) protocol. The org.apache.coyote.http11.Http11Protocol class has been deprecated in Tomcat 9.0, but the Nio protocol works in both Tomcat 8.5 and Tomcat 9.0.
    * Updated to only support TLSv1.2 with current supported ciphers.

Please note that the [Apache Tomcat team announced that support for Apache Tomcat 7.0.x will end on 31 March 2021](https://tomcat.apache.org/tomcat-70-eol.html). As such, LabKey will also no longer support Tomcat 7.0.x as well in the future. We encourage you to upgrade to the latest version of Tomcat to take advantage of the improvements and features that have been made to Tomcat.

* **server_Tomcat-7.x.xml**: Example `server.xml` configuration file for Tomcat7. This configuration file
    * Enables the HTTP connector to listen on port `TCP/80`
    * Enables [access logging](http://tomcat.apache.org/tomcat-7.0-doc/config/valve.html#Access_Logging) using a custom pattern that is described on the [LabKey Community Forums](https://www.labkey.org/home/Support/Inactive%20Forums/Administration%20Forum%20(Inactive)/announcements-thread.view?rowId=4104).
* **server-SSL_Tomcat-7.x.xml**: Example `server.xml` configuration file for Tomcat7. This configuration file
    * Enables the HTTP connector to listen on port `TCP/80`
    * Enables the HTTPS connector to listen on port `TCP/443`
    * HTTPS connector configuration protects against [BEAST](http://blog.zoller.lu/2011/09/beast-summary-tls-cbc-countermeasures.html) and [POODLE](https://www.imperialviolet.org/2014/10/14/poodle.html) attacks.
    * Enables [access logging](http://tomcat.apache.org/tomcat-7.0-doc/config/valve.html#Access_Logging) using a custom pattern that is described on the [LabKey Community Forums](https://www.labkey.org/home/Support/Inactive%20Forums/Administration%20Forum%20(Inactive)/announcements-thread.view?rowId=4104).
    * Updated to only support TLSv1.2 with current supported ciphers.

## Support

If you need support using these scripts/tools or for the LabKey Server in general, please post message to [LabKey Server Community Forum](https://www.labkey.org/home/Support/LabKey%20Support%20Forum/project-begin.view?).

