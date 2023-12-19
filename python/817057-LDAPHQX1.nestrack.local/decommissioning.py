#!/usr/bin/python
import sys, time
import salt.cloud
import salt.client
import argparse

'''
Created by Roger Nem - Jun 2017
Decommissioning script for Jenkins to provisiong server using Salt
split the details from server name e.g. r12345-LDEPHQW.nestrack.local
the server name will be passed as an argument with this script
'''

## Display help message if wrong inputs/parameters provided

class MyHelp(argparse.ArgumentParser):
  def error(self, message):
    sys.stderr.write('error: %s\n' % message)
    self.print_help()
    sys.exit(2)

_help = MyHelp()

_help.add_argument('-n', '--name', action='store', dest='servername',
                    help='Provide server name e.g. r12345-LDEPHQW.nestrack.local')

##Function to delete existing cloud server

def delete_server(arguments):

  ## Creating Cloud Client
  client = salt.cloud.CloudClient('/etc/salt/cloud')

  ## delete server
  client.destroy(arguments.servername)

## Display help message if there is no inputs/parameters provided

if len(sys.argv) < 2:
  _help.print_help()
  sys.exit(1)


## Assign the arguments to the a variable and pass the variable into create_server function

arguments = _help.parse_args()
delete_server(arguments)