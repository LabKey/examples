# DEVELOPER MACHINE INSTRUCTIONS

#### change your password if you haven't already

Click on "activity", then type "terminal" in the search box.  Click on "terminal" to launch.
You might want to right click on the icon in your launcher panel, and select 'Add to favorites'.

Now in your terminal change your password.

**`$`**` passwd`

#### Try building from the command line

**`$`**` cd ~/labkey/trunk`

or

**`$`**` cd ~/labkey/release17.3`

let's sync  the repository before we start (username `cpas`, password `cpas`)

**`$`**` svn update --username cpas`

and build

**`$`**` ./gradlew deployApp`

Note that this has to download a lot of dependencies on the first run.

#### Try building from IntelliJ IDEA

Click on "activity", then type "intellij".  IntelliJ IDEA Ultimate is pre-installed and you can launch it now.  If you don't have (and don't intend
to acquire) a license, you might consider installing IntelliJ IDEA Community edition instead (that's the one under "Ubuntu Software").

Accept all the licenses, and prompts.

_BUG why does intellij try to open a file called 0.000000?_

I'm assuming you have a trunk enlistment, if you have a release enlistment the directory name will be different.

Open an existing project ".../labkey/trunk"

Open the menu "View Tool Windows/Gradle".  Enable auto-import for gradle.

WARNING: It can take a long time to import the gradle project and index the project files the first time.

Run gradle deployApp task which can be found in the tree at :server/Tasks/deploy/deployApp (corresponsds to target "deployApp" on the command line)

#### Run LabKey Server from Intellij IDEA
Wait until your command-line build (or intellij/gradle build) completes.  Then click on the "LabKey DEV" item in the configuration selector
in the toolbar, and click the debug icon.  The server should start up listening on http://localhost:8080/labkey/

Run firefox to find out if it worked!
