Dspace6 
=========

This role will install Dspace6 on a Centos7 box.

Requirements
------------

This role requires the following OU Libraries Ansible Roles:

* OULibraries.centos7
* OULibraries.java


Role Variables
--------------

See `defaults/main.yml` for important variables. 


Example Playbook
----------------

You might do something like this in a vagrant environment:

```
# Build a stand-alone dspace box
- hosts: dspace.vagrant.localdomain
  become: true
  roles:
    - role: OULibraries.postgresql-server
      tags: postgresql-server
    - role: OULibraries.java
      tags: java
    - role: OULibraries.dspace6
      tags: dspace6
```

License
-------

[MIT](https://github.com/OULibraries/ansible-role-dspace/blob/master/LICENSE)

Author Information
------------------

Role developed and maintained by OU Libraries

