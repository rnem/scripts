monitor-services:
    cmd.run:
        - name: |
            #!/bin/bash
            #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            ##  TO MONITOR ESSENCIAL SERVICES (e.g. apache, sssd, etc)                     ##
            ##  Created by Roger Nem - 2016                                                ##
            #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            SERVICE=sssd
            machine=$(hostname)
            email="dl@domain.com"
            if [[ -z $(pgrep $SERVICE) ]]
            then
            echo "Process $SERVICE is not running on $machine!" | mail -s "** CRITICAL: Process $SERVICE is down on $machine **" $email
            if ! /sbin/service $SERVICE start &> /dev/null; then
            echo "Process $SERVICE failed to start on $machine! Please investigate." | mail -s "** CRITICAL: FAILED TO START $SERVICE on $machine **" $email
            else
            echo "Process $SERVICE was restarted on $machine and is up now" | mail -s "** OK: Process $SERVICE is up on $machine **" $email
            fi
            fi
