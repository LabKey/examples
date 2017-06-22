#
# Copyright (c) 2014-2017 LabKey Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
"""
############################################################################
NAME: 
download_study_archive.py 

SUMMARY:  
This program will download a Study Archive to the local directory.

DESCRIPTION:
This program is designed to show how to create and downlaod a Study 
archive from your LabKey Server. This script is written to work with 
LabKey Server v14.X. This script can be modified to perform a full 
folder archive. 

USAGE: 

download_study_archive.py [ -d|--dir DIRECTORY ]

where
    -d, --dir : Directory where the Study archive will be downloaed


In order to download the study archive you will need provide 
credentials. This script assumes that you will provide login credentials 
using a credential file. 

See  https://www.labkey.org/wiki/home/Documentation/page.view?name=setupPython
for instructions on creating the credential file. 


IMPORTANT: In the Variables section below, change the URL, Project and 
Folder Path to point to your LabKey Server.

If you have any questions or need assistance customizing the script for 
your use then post a message to the Developer Support Forums at 
https://www.labkey.org/project/home/Server/Forum/begin.view?


############################################################################
"""

import os
import sys
import time
#import json
import urllib2
import urllib
import base64
import optparse
from poster.encode import multipart_encode
from poster.encode import MultipartParam
from poster.streaminghttp import register_openers


"""
######################################################################
######################################################################
Functions
######################################################################
"""

def _create_opener():   
    """
    Create an opener and load the login and password into the object. The
    opener will be used when connecting to the LabKey Server
    """
    # Check for credential file (which contains login and password for accessing
    # your LabKey Server) in either "LABKEY_CREDENTIALS" environment variable 
    # or in the file .labkeycredentials.txt in your home directory
    try: 
        credential_file_name = os.environ["LABKEY_CREDENTIALS"]
    except KeyError: 
        credential_file_name = os.environ["HOME"] + '/.labkeycredentials.txt'
    
    f = open(credential_file_name, 'r')
    mymachine = f.readline().strip().split(' ')[1]
    myusername = f.readline().strip().split(' ')[1]
    mypassword = f.readline().strip().split(' ')[1]
    f.close()
    
    # Create a password manager
    passmanager = urllib2.HTTPPasswordMgrWithDefaultRealm()
    
    # Add login info to the password manager
    passmanager.add_password(None, mymachine, myusername, mypassword)
    
    # Create the AuthHandler
    authhandler = urllib2.HTTPBasicAuthHandler(passmanager)
    
    # Create opener
    opener = urllib2.build_opener(authhandler)
    return opener

def _create_post_opener():  
    """ 
    Identical to _create_opener object accept this function will create the Basic Authentication 
    Header using the username and password in the credentials file and then will return both 
    the opener object and header string. 
    When submitting a POST, you will need to use this method. 
    """
    # Check for credential file (which contains login and password for accessing
    # your LabKey Server) in either "LABKEY_CREDENTIALS" environment variable 
    # or in the file .labkeycredentials.txt in your home directory
    try: 
        credential_file_name = os.environ["LABKEY_CREDENTIALS"]
    except KeyError: 
        credential_file_name = os.environ["HOME"] + '/.labkeycredentials.txt'
    
    f = open(credential_file_name, 'r')
    mymachine = f.readline().strip().split(' ')[1]
    myusername = f.readline().strip().split(' ')[1]
    mypassword = f.readline().strip().split(' ')[1]
    f.close()

    # Create a password manager
    passmanager = urllib2.HTTPPasswordMgrWithDefaultRealm()

    # Add login info to the password manager
    passmanager.add_password(None, mymachine, myusername, mypassword)

    # Create the AuthHandler
    authhandler = urllib2.HTTPBasicAuthHandler(passmanager)
    
    # Create the Basic Authentication Header
    authHeader = base64.encodestring("%s:%s" % (myusername, mypassword))[:-1]
    authHeader = "Basic %s" % authHeader

    # Create opener
    opener = register_openers()
    return opener, authHeader

"""
######################################################################
End Functions
######################################################################
"""


"""
######################################################################
Variables
######################################################################
"""

# Using the variables below, specify the folder where the file 
# will be uploaded.

labkey_url = "https://www.labkey.org"
labkey_project = "PROJECT"
labkey_folder = "PATH/TO/FOLDER"

"""
######################################################################
End Variables
######################################################################
"""

#
# Read command line options 
#
option_help = "Download the Study archive to this directory. " +\
              "If not specified, the file will be downloaded to the current directory."
usage = "usage: %prog [options]   (Use -h or --help to see all options)"
cl=optparse.OptionParser(usage=usage)
cl.add_option('--dir','-d',action='store',
              help=option_help, type="string", dest="dir")
(options, args) = cl.parse_args()

#
# Check the command line options 
if not options.dir: 
    download_directory = os.getcwd()
else: 
    # Verify that specified in the command line exists
    if os.path.isdir(options.dir):
        download_directory = os.path.abspath( options.dir )
    else: 
        cl.error("The directory specified on the command line does not exist or cannot be accessed. \n")


#
# Export the study from the downloadUrl Labkey Server 
#
print "\n" + sys.argv[0] + " is starting"

#
# Get authenticated to send URL requests. This uses the file defined the 
# LABKEY_CREDENTIALS environment variable.  Change/set the environment 
# variable to use downloadCredentialFile
opener, aHeader = _create_post_opener()

#
# URL to be used to be used for exporting/download the study archive
container_path = labkey_project + "/" + labkey_folder
myurl = labkey_url.rstrip('/') +\
    "/admin/" +\
    urllib2.quote(container_path.strip('/')) +\
    "/folderManagement.view?tabId=export&exportType=study"

#
# Create the postdata which was submitted with the POST
# For the Study Export, you can select what will be exported. All checkboxes
# selected are given a form field name of "types". In Python to get this to work, 
# we have to submit all fields with a name of "types" as an array. 
types = [
    'Missing value indicators',
    'Study',
    'Assay Datasets',
    'Assay Schedule',
    'Categories',
    'Cohort Settings',
    'CRF Datasets',
    'Custom Participant View',
    'Participant Comment Settings',
    'Participant Groups',
    'Protocol Documents',
    'QC State Settings',
    'Specimen Settings',
    'Specimens',
    'Treatment Data',
    'Visit Map',
    ]

# Create dictionary of postdata 
mypostdata_unencoded = {\
    'types': types,
    'format': 'new',
    '@includeSubfolders': '',
    '@removeProtected': '',
    '@shiftDates': '',
    '@alternateIds': '',
    '@maskClinic': '',
    'location': '2'}  

# Encode the postdata before sending
mypostdata = urllib.urlencode(mypostdata_unencoded, doseq=True)
#print mypostdata_unencoded
#print mypostdata

#
# Create the request, using the BASIC AUTH header we created above. 
myrequest = urllib2.Request(myurl,None,{"Authorization": aHeader })

#
# Submit the request to create and download the Study archive.
print "\nDownload the study archive from " + myurl
print " -- Start-time: " + str(time.strftime("%c"))


try:
    response = opener.open(myrequest,mypostdata)

    # Get filename from the response headers. The file name is surrounded by double quotes. 
    response_headers = response.info()
    download_file_name = response_headers["Content-Disposition"].split("=")[1]
    if download_file_name.startswith('"') and download_file_name.endswith('"'):
        download_file_name = download_file_name[1:-1]

    download_full_path = os.path.join(download_directory, download_file_name)
    # print download_full_path

    # Stream the data to the filesystem
    local_file = open(download_full_path, "wb")
    chunk = 4096
    while 1:
        data = response.read(chunk)
        if not data:
            break
        local_file.write(data)

    # The download has been successful 
    local_file.close() 
    print " -- Completed at: " + str(time.strftime("%c"))
    print "The study archive has been successfully downloaded to " + download_full_path 
except urllib2.HTTPError, e:
    msg = "There was problem while attempting to download the study archive from " + str(e.geturl()) + ". The HTTP response code was " + str(e.getcode())
    print "\n" + msg
    print "The HTTP client error was: "+ format(e)
    #print "The HTTP Response Headers are: \n" + str(e.info())
    #print "The Response Body is \n" + e.read()
    print sys.argv[0] + " encountered a problem and has quit\n"
    sys.exit(1)
except urllib2.URLError, e:
    msg = "There was problem connecting to the Download Server: " + myurl
    print "\n" + msg
    print "The error message is " + e.reason 
    print sys.argv[0] + " encountered a problem and has quit\n"
    sys.exit(1)
except IOError as e:
    msg = "There was problem writing to the file " + download_full_path
    print "\n" + msg
    print "The error message is " + format(e)
    print sys.argv[0] + " encountered a problem and has quit\n"
    sys.exit(1)


#
# Upload was a success. Print the URL of the newly uploaded file.
status = 0
file_url = myurl.rstrip('/') + "/" + os.path.basename(download_file_name)
print "The Study Archive has been successfully downloaded to " + download_full_path
print "\n"




