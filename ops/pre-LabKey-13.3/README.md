
This folder contains install and upgrade scripts for [LabKey Server](https://www.labkey.org/) **versions 13.2 and earlier**.

**IMPORTANT:** *If you are running LabKey Server v13.3 (which was released in 11/2013) or later, <strong>do not use the scripts in this folder</strong>. Please use the scripts [here](https://github.com/LabKey/samples/tree/master/ops)*


## Available Scripts

* **install-windows-manual.bat**: Use script to install the LabKey Server binaries on Windows. This should only be used if you are performing at [manual installation](https://www.labkey.org/wiki/home/Documentation/page.view?name=manualInstall).
    * This script should only be used to install LabKey Server v13.2 or earlier.
    * This should only be used if you are performing at [manual installation](https://www.labkey.org/wiki/home/Documentation/page.view?name=manualInstall) on a Windows server.
    * This script is not officially supported by LabKey.
* **upgrade-windows-manual.bat**:  Use script to upgrade a LabKey Server running on Windows, which was manually installed. 
    * This script should only be used to upgrade LabKey Server v13.2 or earlier.
    * [Instruction](https://www.labkey.org/announcements/home/Server/Administration/thread.view?rowId=4842)
    * Do not use this script if you installed your LabKey Server using the [Windows Installer](https://www.labkey.org/wiki/home/Documentation/page.view?name=configWindows). Please use the Windows Installer to upgrade your server
    * This script is not officially supported by LabKey, but it is used by a number of labs and institutions running LabKey Server on Windows. 
    * If you have questions or need support, please post a message on the [LabKey Server Community Forum](https://www.labkey.org/project/home/Server/Forum/begin.view?).
* **upgrade-remote-pipeline.sh**: Use script to upgrade a LabKey Remote Pipeline Server running on \*nix operating system.
    * This script should only be used to install LabKey Server v13.2 or earlier.
    * This script is not officially supported by LabKey and there is currently no documentation for it. However, I regularly use a modified version of this on my test servers. 
    * If you have questions or need support, please post a message on the [LabKey Server Community Forum](https://www.labkey.org/project/home/Server/Forum/begin.view?).
* **upgrade-remote-pipeline.bat**: Use script to upgrade a LabKey Remote Pipeline Server running on Windows that was installed manually.
    * This script should only be used to install LabKey Server v13.2 or earlier.
    * This script is not officially supported by LabKey and there is currently no documentation for it. However, I regularly use a modified version of this on my test servers.
    * Do not use this script if you installed your LabKey Remote Pipeline Server using the [Windows Installer](https://www.labkey.org/wiki/home/Documentation/page.view?name=configWindows). Please use the Windows Installer to upgrade your server.
    * If you have questions or need support, please post a message on the [LabKey Server Community Forum](https://www.labkey.org/project/home/Server/Forum/begin.view?).

## Support 

If you need support using these scripts/tools or for the LabKey Server in general, please post message to [LabKey Server Community Forum](https://www.labkey.org/project/home/Server/Forum/begin.view?). Or send me a message on [twitter](https://twitter.com/bdconnolly)([@bdconnolly](https://twitter.com/bdconnolly)).



