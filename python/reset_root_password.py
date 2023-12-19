#!/usr/bin/env python
#################################################################
# Reset admin password - Cloud VMs - Account #12345678          #
# Created by Roger Nem - 2016                                   #
# History:                                                      #
# v0.001  - Roger Nem - First Version                           #
#################################################################

# Loding required modules
import os
import sys
import requests
import json
import csv
import warnings
import pycurl, json

#/usr/lib/python2.6/site-packages/urllib3/connection.py:251: SecurityWarning: Certificate has no `subjectAltName`, falling back to check for a `commonName` for now. This feature is being removed by major browsers and deprecated by RFC 2818. (See https://github.com/shazow/urllib3/issues/497 for details.) - SecurityWarning
import urllib3
urllib3.disable_warnings()

import requests.packages.urllib3
requests.packages.urllib3.disable_warnings()

warnings.filterwarnings("ignore")

## VARIABLES ##### ##########################
accountID="*****"
username="*****"
apiKey="*****"
output='results.csv'
whatserver = raw_input("What server? ")
newpasswd = raw_input("New passwd? ")
###########################################

# Authenticate Token
# curl -s https://identity.api.clouddomain.com/v2.0/tokens -X 'POST'  -d '{\"auth\":{\"RAX-KSKEY:apiKeyCredentials\":{\"username\":\"$username\", \"apiKey\":\"$apiKey\"}}}'  -H \"Content-Type: application/json\" | python -m json.tool

# Authenticate to get Token
authURL = 'https://identity.api.clouddomain.com/v2.0/tokens'
authPayload= {'auth': {'RAX-KSKEY:apiKeyCredentials': {'username': username,'apiKey': apiKey}}}
authHeaders = {'content-type': 'application/json'}
authResponse = requests.post(authURL, data=json.dumps(authPayload), headers=authHeaders)
authResponseJson = json.loads(authResponse.text)

authToken = authResponseJson['access']['token']['id']

#print "Authentication Token:",authToken

# Get serverList
# The maximum number of items returned is 1000
listURL = "https://lon.servers.api.clouddomain.com/v2/%s/servers" % (accountID)
listHeaders = {'content-type': 'application/json', 'X-Auth-Token': authToken}
listResponse = requests.get(listURL, headers=listHeaders)
listResponseJson = json.loads(listResponse.text)

# Get Image type
def getImageOS(authToken, accountID, imageID):        
	imageURL = "https://lon.servers.api.clouddomain.com/v2/%s/images/%s" % (accountID, imageID)
        imageHeaders = {'content-type': 'application/json', 'X-Auth-Token': authToken}
        imageResponse = requests.get(imageURL, headers=imageHeaders)
        imageResponseJson = json.loads(imageResponse.text)
        try:
                imageOS = imageResponseJson['image']['metadata']['os_type']
        except KeyError:
                imageOS = imageResponseJson
        return imageOS

# Clear existing file
try:
    os.remove(output)
except OSError:
    pass

# Create new output file
orig_stdout = sys.stdout
f = file(output, 'w')
sys.stdout = f

for server in listResponseJson['servers']:
        print server['name']+','+server['id']

sys.stdout = orig_stdout
f.close()

# READ output file for info
with open(output, 'rt') as f:
     reader = csv.reader(f, delimiter=',')
     for row in reader:
          if row[0] == whatserver :
                serverID = row[1]
                
# RS Portal - Detail URL to confirm the server is correct using the ID given
# https://mycloud.domain.com/dedicated/12345678/servers#compute%2CcloudServersOpenStack%2CLON/{SERVERID}

# Reset root passwd
# curl -v -H "X-Auth-Token:  authToken"  -H "Content-Type: application/json" -H "Accept: application/json" -X POST https://lon.servers.api.clouddomain.com/v2/accountID/servers/SRVID/action -d '{"changePassword":{"adminPass":"'+newpasswd+'"}}'

passwdURL = "https://lon.servers.api.clouddomain.com/v2/%s/servers/%s/action" % (accountID, serverID)
passwdPayload= {'changePassword': {'adminPass': newpasswd }}
passwdHeaders = {'content-type': 'application/json', 'X-Auth-Token': authToken}
passwdResponse = requests.post(passwdURL, data=json.dumps(passwdPayload), headers=passwdHeaders)

# No Json response. Just the regular one.
print passwdResponse
print "The admin password of the server " + whatserver + " with ID " + row[1] + " was successfully changed"

# Security - Delete file
os.remove(output)