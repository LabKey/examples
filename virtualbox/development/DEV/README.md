DEVELOPER MACHINE INSTRUCTIONS

#### open a terminal

Click on "activity", then type "terminal" in the search box.  Click on "terminal" to launch.
You might want to right click on the icon in your launcher panel, and select 'Add to favorites'.

Now in your terminal change your password.

**`$`**` passwd`

#### Try building from the command line

**`$`**` cd ~/labkey/trunk`

or

**`$`**` cd ~/labkey/release17.3`

then

**`$`**` ./gradlew pickPg`

**`$`**` ./gradlew deployApp`

#### Try building from IntelliJ IDEA

Click on "activity", then type "intellij".  IntelliJ IDEA Ultimate is pre-installed and you can launch it now.  If you don't have (and don't intend
to acquire) a license, you might consider installing IntelliJ IDEA Community edition instead (that's the one under "Ubuntu Software").

Accept all the licenses, and prompts.

_BUG why does intellij try to open a file called 0.000000?_

I'm assuming you have a trunk enlistment, if you have a release enlistment the directory name will be different.

Open an existing project ".../labkey/trunk"

Open your project settings and add a new JDK, the suggested default (oracle 1.8) will work.

Open the "Run/Edit Configurations" menu item.  Select "LabKey Dev".  Under "VM Options" make sure the class path uses colons ':' rather than semi-colons ';'.

_BUG fix the classpath so that it does not have semi-colons_

Open the menu "View Tool Windows/Gradle".  Enable auto-import for gradle.

**WARNING: It can take a long time to import the gradle project and index the project files the first time.**  

Run gradle deployApp task which can be found in the tree at :server/Tasks/deploy/deployApp (corresponsds to target "deployApp" on the command line)

#### Run LabKey Server from Intellij IDEA
Wait until your command-line build (or intellij/gradle build) completes.  Then click on the "LabKey DEV" in the configuration selector
in the toolbar, and click the debug icon.  The server should start up listening on http://localhost:8080/labkey/

If you see "Error: Could not find or load main class org.apache.catalina.startup.Bootstrap" in the Debugger Console, you did not fix up your class path (see above).

Run firefox to find out if it worked!