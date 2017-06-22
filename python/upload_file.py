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
upload_file 

SUMMARY:  
This program will upload a file to your LabKey Server.

DESCRIPTION:
This program is designed to show how a file can be uploaded to a 
LabKey Server using Python. 

USAGE: 

upload_file.py -f|--file filename 

where
    -f, --file : File to be uploaded to LabKey Server 


In order to upload a file to the LabKey Server you will need provide 
credentials. This script assumes that you will provide login credentials 
using a credential file. 

See https://www.labkey.org/wiki/home/Documentation/page.view?name=setupPython
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
import json
import urllib2
import urllib
import base64
import optparse
from poster.encode import multipart_encode
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

labkey_url = 'https://www.labkey.org'
labkey_project = 'PROJECT'
labkey_folder = 'PATH/TO/FOLDER'

"""
######################################################################
End Variables
######################################################################
"""

#
# Read command line options 
#
usage = "usage: %prog [options]   (Use -h or --help to see all options)"
cl=optparse.OptionParser(usage=usage)
cl.add_option('--file','-f',action='store',
              help="Read the content for the message from this file", type="string", dest="file")
(options, args) = cl.parse_args()

#
# Check the command line options 
if not options.file: 
    cl.error("You must specify a file to be uploaded. Use -h for more information.\n")

if options.file: 
    if os.path.isfile(options.file): 
        file_name = options.file
    else: 
        cl.error("The file specified on the command line does not exist or cannot be accessed. \n")


#
# Upload the file to the LabKey Server running at labkey_url
# 

#
# Get authenticated to send the file. 
opener, aHeader = _create_post_opener()


#
# URL to be used to be used for uploading the file
container_path = labkey_project + "/" + labkey_folder
myurl = labkey_url.rstrip('/') +\
    "/_webdav/" +\
    urllib2.quote(container_path.strip('/')) + "/%40files"
#print myurl


#
# The next step is to create the multipart/form-data postdata. 
# Start the multipart/form-data encoding of the download_file_path.
# - headers contains the necessary Content-Type and Content-Length
# - datagen is a generator object that yields the encoded parameters
try: 
    datagen, headers = multipart_encode({"filename": open(file_name, "rb")})
except IOError as e:
    status = 1
    error_message = "There was an error during encoding of file. Error message = " + format(e)
    print error_message
    sys.exit(status)


#
# Create the request, using the BASIC AUTH header we created above. 
myrequest = urllib2.Request(myurl, datagen, headers)
myrequest.add_header('Authorization', aHeader ) # Add Auth header to request
try:
    response = opener.open(myrequest)
except urllib2.HTTPError, e:
    status = 1
    error_message = "There was problem while attempting to upload the file to " + str(e.geturl()) + \
            ".\n The HTTP response code was " + str(e.getcode()) + \
            "\nThe HTTP client error was: "+ format(e)
    #print "The HTTP Response Headers are: \n" + e.info()
    #print "The Response Body is \n" + e.read()
    print error_message
    sys.exit(status)


#
# Upload was a success. Print the URL of the newly uploaded file.
status = 0
file_url = myurl.rstrip('/') + "/" + os.path.basename(file_name)
print "The file upload was successful. You can see the uploaded file at " + file_url
print "\n"




