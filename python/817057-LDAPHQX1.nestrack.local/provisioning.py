#!/usr/bin/python
import sys, time
import salt.cloud
import salt.client
import argparse
import json

'''
Created by Roger Nem - Jun 2017
Provisioning script for Jenkins to provisiong server using Salt
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
                    help='Provide server name e.g. r12345-LDEPHQW.nestrack.local(Dedicated) or r54432-idapw22a.nestrack.local(Shared)')
_help.add_argument('-u', '--url',default='localhost.localdomain', action='store', dest='url',
                    help='Provide the domain name e.g. websitename.com')
_help.add_argument('-o', '--offering',default='small', action='store', dest='offering',
                    help='''Provide required offering e.g. small, medium and large. default is small.
                         small offering includes Staging 1 x 1GB/1CPU/20GB and Prod 2x 2GB/2CPU/40GB
                         medium offering includes Staging 1 x 2GB/2CPU/40GB and Prod 2x 4GB/4CPU/80GB
                         large offering  includes Staging 1 x 4GB/4CPU/80GB and Prod 2x 8GB/8CPU/160GB)
                         shared offering  includes Staging 1 x 4GB/4CPU/80GB and Prod 2x 8GB/8CPU/160GB''')


##Function to create new cloud server

def create_server(arguments):

  ##Capture the server details server location, type, environment etc.

  args = str(arguments.servername).split('-', 1)[1].split('.',1)[0].upper()
  digipid = str(arguments.servername).split('-', 1)[0].split('.',1)[0].upper()

  if args[2] != 'a':
    ##Verify DiGiPi ID
    if len(digipid) > 6:
      print "Please check the DigiPI ID"
      sys.exit(1)
    else:
      print "Shared server no DigiPI ID required"

  _domainname = arguments.url.replace('www.','')
  _servername = str(arguments.servername)
  _location = args[0]
  _hosting = args[2]
  _environment = args[3]
  _market = ''
  _role = 'W'

  #if dedicated server then only parse the market name and role
  if _environment.lower() == 'e':
        _market = args[4:6]
        _role = args[6]

  _offering = str(arguments.offering)
  provider = ''


  ## Definations dictionary of server information e.g. hosting type, evnvironment, role and location

  hostings = {'A':'Shared', 'B': 'Web Containers', 'C':'DolceG', 'D':'SpecialT', 'E':'Dedicated','F':'Foundation Services',
            'R':'RIKI'}

  environments = {'B':'DR','D':'Development','P':'Production', 'S':'Staging'}

  roles = {'A':'Antivirus','B':'Bastion','C':'Capistrano','D':'Database','E':'Storage','F':'Firewall','G':'GIT','J':'Jenkins',
         'K':'Log Server','L':'Load Balancer','M':'Mail','N':'Cluster Node','O':'Other','R':'Redis / Memcache','S':'SFTP',
         'T':'Tools','V':'Varnish','W':'Web Server','X':'Salt Master','Z':'NFS'}

  locations = {'L':'London','G':'London','O':'Chicago','H':'Hongkong'}
  zones = {'L':'LON','G':'LON','O':'ORD','H':'HKG'}

  ## Selecting hosting provider profile based on the location of requested server

  if _location == 'L' or _location == 'G':
    if _hosting == 'E':
      provider = 'nestdsulonm'
    elif _hosting == 'A':
      provider = 'nestdsulons'
  elif _location == 'O':
    if _hosting == 'E':
      provider = 'nestdsuordm'
    elif _hosting == 'A':
      provider = 'nestdsuords'
  elif _location == 'H':
    if _hosting == 'E':
      provider = 'nestdsuhkgm'
    elif _hosting == 'A':
      provider = 'nestdsuhkgs'

  _profile = provider+'_'+_offering+'_'+environments[_environment]


  ## Creating Cloud Client
  client = salt.cloud.CloudClient('/etc/salt/cloud')

  ## Using specific salt cloud profile based on
  client.profile(_profile.lower(),_servername.lower(), kwargs={'grains':{'website_name':_domainname,
                                                                         'market':'NEST' + _market,
                                                                         'zone':zones[_location],
                                                                         'hosting':hostings[_hosting],
                                                                         'type':roles[_role],
                                                                         'location':locations[_location]
                                                                        }})

  ## Wait 20 seconds for salt-cloud to do the cleanup
  time.sleep(60)

  ## Creating salt client and applying salt state

  local = salt.client.LocalClient()

  #Salt state apply
  local.cmd(_servername.lower(), 'state.apply')


  #Workaround to install mysql client package
  time.sleep(60)
  local.cmd(_servername.lower(),'cmd.run', ['rpm --nodeps -e mysql-libs;yum install -y mysql56u'])


  ## Collect information and print the information, once server is built

  response = {'Hosting':hostings[_hosting], 'Environment': environments[_environment], 'Role':roles[_role],
              'Location':locations[_location], 'ServerName': _servername, 'vHost':_domainname.replace('.','_'),
              'OU': 'NEST' + _market, 'Size': _offering,}
  print json.JSONEncoder().encode(response)


## Display help message if there is no inputs/parameters provided

if len(sys.argv) < 4:
  _help.print_help()
  sys.exit(1)


## Assign the arguments to the a variable and pass the variable into create_server function

arguments = _help.parse_args()
create_server(arguments)