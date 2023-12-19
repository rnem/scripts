# Created by Roger Nem (c) 2017

{% if not salt['file.directory_exists' ]('/tmp/audit') %}
/tmp/audit:
  file.directory:
    - name:  /tmp/audit   
    - user:  root
    - group: root
    - mode:  700
{% endif %}

#{% if grains['os'] == 'CentOS' or grains['os'] == 'RedHat' %}
#{% elif grains['os'] == 'Ubuntu'%}
#{% endif %}

version-finder:
    cmd.run:
        - name: |
            #!/bin/bash
            result="/tmp/audit/audit.txt"
            
            if [ -f $result ]; then
            rm -f $result
            fi
            
            hostname=$(hostname)
            
            #tmp_OSBRAND=$(cat /etc/*-release | /usr/bin/cut -d' ' -f1 | /usr/bin/cut -d'=' -f2 | /usr/bin/head -n 1)
            #case $tmp_OSBRAND in
            #Red)
            #OSBRAND="RHEL"
            #;;
            #CentOS)
            #OSBRAND="CentOS"
            #;;
            #Ubuntu)
            #OSBRAND="Ubuntu"
            #;;
            #*)
            #OSBRAND="Other"
            #;;
            #esac
            
            OSAndVersion=$(cat /etc/*-release |head -1)
            
            web_server=$(lsof -nPi | grep ':80 (LISTEN)' | grep -v root |cut -d' ' -f1 | sort --unique)
            case $web_server in
            apache2)
            web_server_version=$(apache2 -v |head -1)
            ;;
            nginx)
            #web_server_version=$(nginx -v)
            web_server_version=$(rpm -qi nginx |grep Version | cut -d: -f2 | cut -d' ' -f2)
            ;;
            httpd|httpd.wor)
            web_server_version=$(httpd -v | head -1)
            ;;
            varnishd)
            #web_server_version=$(varnishd -V | head -1)
            web_server_version=$(rpm -qi varnish.x86_64 |grep Version | cut -d: -f2 | cut -d' ' -f2)
            ;;
            *)
            web_server_version="N/A"
            ;;
            esac
            
            php_version=$(php -v 2> /dev/null | head -1)
            
            #Server,OS,ActiveWebServer,ActiveWebServerVersion,PHPVersion
            echo "$hostname,$OSAndVersion,$web_server,$web_server_version,$php_version" >> $result