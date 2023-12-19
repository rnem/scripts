/etc/resolv.conf:
  file.managed:
    - user: root
    - group: root
    - contents:
{% if grains['location'] == 'lon3' %}
      - nameserver 1.2.3.4
      - nameserver 1.2.3.5
{% elif grains['location'] == 'hkg' %}
      - nameserver 1.3.4.6
      - nameserver 1.3.4.7
{% elif grains['location'] == 'ord' %}
      - nameserver 1.4.4.8
      - nameserver 1.4.4.9
{% endif %}
      - domain nestrack.local
/etc/krb5.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source: salt://active-directory/files/krb5.conf
    - require:
      - pkg: krb5-workstation

/etc/auth_kerb.keytab:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source: salt://active-directory/files/auth_kerb.keytab
    - require:
      - pkg: krb5-workstation

/etc/sudoers:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - source: salt://active-directory/files/sudoers

/etc/samba/smb.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - source: salt://active-directory/files/smb.conf
    - require:
      - pkg: samba

/etc/sssd/sssd.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - source: salt://active-directory/files/sssd.conf
    - require:
      - pkg: sssd

ad-packages:
  pkg.installed:
    - names:
      - sssd
      - krb5-workstation
      - samba
join-domain:
  cmd.run:
    - name: net ads join -U {{ salt['pillar.get']('active-directory:username') }}%{{ salt['pillar.get']('active-directory:password')}}
    - watch:
      - file: /etc/samba/smb.conf
    - unless: net ads testjoin 2>&1|grep -i OK

sssd:
  service:
    - enable: True
    - running
    - watch:
      - file: /etc/sssd/sssd.conf
    - require:
      - pkg: sssd

auth-config:
  cmd.run:
    - name: authconfig --update --enablesssd --enablesssdauth --enablemkhomedir
    - unless: grep sss /etc/pam.d/system-auth
    - require:
      - file: /etc/sssd/sssd.conf