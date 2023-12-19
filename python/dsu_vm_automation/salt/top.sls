## /srv/salt/top.sls

base:
  'os:(RedHat|CentOS)':
      - match: grain_pcre
      - yum
      - active-directory.linux
      - banner.linux
      - common.linux
      - apache
      - php