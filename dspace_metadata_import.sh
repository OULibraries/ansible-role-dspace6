#!/usr/bin/env bash


########################################################################################
## Run this script to import metadata from old dspace into new dspace6 database, and  ##
## copy over the metadata registry files.											  ##
########################################################################################


## Refer to : https://unix.stackexchange.com/questions/191990/shell-script-to-execute-psql-command ##
## DSpace6 Upgrading: https://wiki.duraspace.org/display/DSDOC6x/Upgrading+DSpace ##


#########################################################################
#                       									 			#
#	Need to 															#
#		1) copy over the dumped pgsql file from old dspace, and			#
#		2) set up the ownership, and									#
#		3) replace the user to be dspace or something, and 				#
#		4) comment out the block of adding rule protect_approval_upd	#
#    	5) comment out the privileges granted to user libacct			#
#                       												#
#########################################################################

PATH_TO_REGISTRIES_FROM_OLD_DSPACE = /vagrant/registries.tar.gz
PATH_TO_OLD_DSPACE_DATABASE_DATA = /vagrant/test3.pgsql


echo "#####  Create new database dspace2  #####"

sudo -u postgres psql <<EOF

DROP DATABASE IF EXISTS dspace2;

CREATE DATABASE dspace2 WITH OWNER dspace; 

\c dspace2

CREATE EXTENSION pgcrypto;

EOF

echo "#####  Import metadata into database dspace2  #####"

sudo -u postgres psql -U dspace -h localhost dspace2 < $PATH_TO_OLD_DSPACE_DATABASE_DATA

sudo -u postgres psql <<EOF

\c dspace2

ALTER DATABASE dspace RENAME TO dspace_old;

REVOKE CONNECT ON DATABASE dspace2 FROM public;

SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'dspace2';

ALTER DATABASE dspace2 RENAME TO dspace;

EOF

echo "#####  Show database info  #####"

sudo /srv/oulib/dspace/bin/dspace database info

echo "#####  Running database upgrade script  #####"

sudo /srv/oulib/dspace/bin/dspace database migrate

echo "#####  Modified imported metadata in dspace2  #####"

sudo -u postgres psql <<EOF

\c dspace2

ALTER DATABASE dspace RENAME TO dspace_old;

CREATE RULE protect_approval_upd AS
    ON UPDATE TO workflowitem
   WHERE ((new.state = ANY (ARRAY[2, 4, 6])) AND (new.owner IN ( SELECT item.submitter_id
           FROM item
          WHERE (item.item_id = new.item_id)))) DO INSTEAD NOTHING;

EOF

echo "#####  Copy over the registry files  #####"
sudo mv /srv/oulib/dspace/config/registries/ /srv/oulib/dspace/config/registries-old/
sudo tar -xvf $PATH_TO_REGISTRIES_FROM_OLD_DSPACE
sudo mv /vagrant/registries /srv/oulib/dspace/config
sudo chown -R tomcat:tomcat /srv/oulib/dspace/config/registries/

echo "#####  Restart Tomcat service  #####"
sudo systemctl restart tomcat

echo "#####  Finished Database section  #####"
exit