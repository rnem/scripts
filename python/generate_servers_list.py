#!/usr/bin/env python

DOCUMENTATION = '''
---
module: generate_servers_list
short_description: Get Cloud Server List
description:
     - Get Cloud Server List.
author:
    - "Roger Nem"
'''

import os
import sys
import requests
import json
import csv
import warnings
import pycurl, json

## VARIABLES ##### ##########################
accountID="*****"
username="*****"
apiKey="*****"
output='servers_list.csv'
###########################################

# Authenticate to get Token
authURL = 'https://identity.api.clouddomain.com/v2.0/tokens'
authPayload= {'auth': {'RAX-KSKEY:apiKeyCredentials': {'username': username,'apiKey': apiKey}}}
authHeaders = {'content-type': 'application/json'}
authResponse = requests.post(authURL, data=json.dumps(authPayload), headers=authHeaders)
authResponseJson = json.loads(authResponse.text)

authToken = authResponseJson['access']['token']['id']

with open("authToken", "w") as text_file:
    text_file.write(authToken)

# Get serverList - The maximum number of items returned is 1000
listURL = "https://lon.servers.api.clouddomain.com/v2/%s/servers" % (accountID)
listHeaders = {'content-type': 'application/json', 'X-Auth-Token': authToken}
listResponse = requests.get(listURL, headers=listHeaders)
listResponseJson = json.loads(listResponse.text)

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
        print server['id']+','+server['name']

sys.stdout = orig_stdout
f.close()