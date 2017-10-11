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

PATH_TO_REGISTRIES_FROM_OLD_DSPACE=/tmp/registries.tar.gz
PATH_TO_OLD_DSPACE_DATABASE_DATA=/tmp/test3.pgsql
EXISTING_DSPACE_DATABASE_NAME=dspace
EXISTING_DSPACE_DATABASE_NAME_CHANGED=dspace_old
NEW_DSPACE_DATABASE_NAME=dspace2
DSPACE_DATABASE_OWNER=dspace

sudo systemctl stop tomcat

echo "#####  Create new database with a new name  #####"

sudo -u postgres psql <<EOF

DROP DATABASE IF EXISTS $NEW_DSPACE_DATABASE_NAME;

DROP DATABASE IF EXISTS $EXISTING_DSPACE_DATABASE_NAME_CHANGED;

CREATE DATABASE $NEW_DSPACE_DATABASE_NAME WITH OWNER $DSPACE_DATABASE_OWNER; 

\c $NEW_DSPACE_DATABASE_NAME

CREATE EXTENSION pgcrypto;

EOF

echo "#####  Import metadata into the new database  #####"

sudo -u postgres psql -U $DSPACE_DATABASE_OWNER -h localhost $NEW_DSPACE_DATABASE_NAME < $PATH_TO_OLD_DSPACE_DATABASE_DATA

echo "##### Modify the databases #####"

sudo -u postgres psql <<EOF

ALTER DATABASE $EXISTING_DSPACE_DATABASE_NAME RENAME TO $EXISTING_DSPACE_DATABASE_NAME_CHANGED;

\c $EXISTING_DSPACE_DATABASE_NAME_CHANGED

ALTER DATABASE $NEW_DSPACE_DATABASE_NAME RENAME TO $EXISTING_DSPACE_DATABASE_NAME;

\q

EOF

echo "#####  Copy over the registry files  #####"
sudo mv /srv/oulib/dspace/config/registries/ /srv/oulib/dspace/config/registries-old/
sudo tar -xvf $PATH_TO_REGISTRIES_FROM_OLD_DSPACE -C /tmp
sudo mv /tmp/registries /srv/oulib/dspace/config
sudo chown -R tomcat:tomcat /srv/oulib/dspace/config/registries/

echo "#####  Restart Tomcat service  #####"
sudo systemctl start tomcat

echo "#####  Finished Database section  #####"
exit