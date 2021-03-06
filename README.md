Dspace6 
=========

This role will install Dspace6 on a Centos7 box.

It provides the following scripts for managing your DSpace install:

* `bin/build.sh` - runs `maven` build 
* `bin/install.sh` - runs `ant` install
* `bin/clean.sh` - runs `maven` clean    
* `bin/fix_perms.sh` - applies known-good permissions and selinux context
* `bin/git_pull.sh` - updates dspace source with correct permissions

These scripts will be installed in the path specified by the `dspace_install_dir` role variable, along with:
* `dspace` - the DSpace app directory
* `dspace-src` - the DSpace source code
* `etc` - assorted config files

Additionally, if the handle variables are configured, the DSpace handle server will be installed as a `systemd` service.


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

