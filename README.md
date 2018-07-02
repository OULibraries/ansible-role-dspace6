Dspace6 
=========

This role will install Dspace6 on a Centos7 box.

Requirements
------------

This role requires the following OU Libraries Ansible Roles:

	* Centos7
	* Postgresql-server
	* Users

Role Variables
--------------

Place the following in your host vars or my-vars.yml file:

```
dspace_install_dir:
dspace_dn_prefix:
dspace_dn_suffix:
dspace_site_name: 
dspace_db_username:
dspace_db_password:
```

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }
License
-------

[MIT](https://github.com/OULibraries/ansible-role-dspace/blob/master/LICENSE)

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
