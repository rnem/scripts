#!/usr/bin/env python2
# -.- coding: utf-8 -.-

DOCUMENTATION = '''
---
module: audit_users
short_description: Info about local user accounts
description:
     - Information about local user accounts in Linux.
author:
    - "Roger Nem"
'''

import os, pwd, grp

def main():

    users = {}

    if not os.path.exists("/etc/passwd"):
        print "/etc/passwd does not exist"

    if not os.path.exists("/etc/shadow") or not os.access("/etc/shadow", os.R_OK):
        print "unable to open /etc/shadow"

    for line in open("/etc/passwd").readlines():
        data = line.strip().split(":")

        user_name = data[0]
        user = {
            "uid": data[2],
            "gid": data[3],
            "home": data[5],
            "shell": data[6],
            "can_login": True # default
        }

        if user["shell"] in ("/usr/sbin/nologin", "/sbin/nologin", "/bin/false"):
            user["can_login"] = False

        users[user_name] = user

        print user_name, user

main()