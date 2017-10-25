#!/usr/bin/env bash


########################################################################################
## Run this script to import metadata from old dspace into new dspace6 database, and  ##
## copy over the metadata registry files.                                             ##
########################################################################################


## Refer to : https://unix.stackexchange.com/questions/191990/shell-script-to-execute-psql-command ##
## DSpace6 Upgrading: https://wiki.duraspace.org/display/DSDOC6x/Upgrading+DSpace ##


#################################################################################
#                                                                               #
#       Need to                                                                 #
#		1) copy over the dumped pgsql file from old dspace, and         #
#		2) set up the ownership, and                                    #
#		3) replace the user to be dspace or something, and              #
#		4) comment out the block of adding rule protect_approval_upd    #
#               5) comment out the privileges granted to user libacct           #
#                                                                               #
################################################################################


EXISTING_DSPACE_DATABASE_NAME_CHANGED=dspace_changed_from_existing_temp
NEW_DSPACE_DATABASE_NAME=dspace_new_temp

while getopts o:p:q:r:s:t: option
  do
    case "${option}"
    in
      o) PATH_TO_REGISTRIES_FROM_OLD_DSPACE=${OPTARG};;
      p) PATH_TO_OLD_DSPACE_DATABASE_DATA=${OPTARG};;
      q) EXISTING_DSPACE_DATABASE_NAME=${OPTARG};;
      r) DSPACE_DATABASE_OWNER=${OPTARG};;
      s) DATABASE_HOSTNAME=$OPTARG;;
    
 esac
done

if [[ -z "${PATH_TO_REGISTRIES_FROM_OLD_DSPACE// }" ]]; then
	echo "ERROR: the path to the registries of the old dspace instance is not defined!"
	exit
fi

if [[ -z "${PATH_TO_OLD_DSPACE_DATABASE_DATA// }" ]]; then
	echo "ERROR: the path to the database data file of the old dspace instance is not defined!"
	exit
fi

if [[ -z "${EXISTING_DSPACE_DATABASE_NAME// }" ]]; then
	echo "ERROR: the name of the database of the existing dspace instance is not defined!"
	exit
fi

if [[ -z "${DSPACE_DATABASE_OWNER// }" ]]; then
	echo "ERROR: the name of the dspace database owner is not defined!"
	exit
fi

if [[ -z "${DATABASE_HOSTNAME// }" ]]; then
	echo "ERROR: the hostname of the dspace database is not defined!"
	exit
fi


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

sudo -u postgres psql -U $DSPACE_DATABASE_OWNER -h $DATABASE_HOSTNAME $NEW_DSPACE_DATABASE_NAME < $PATH_TO_OLD_DSPACE_DATABASE_DATA

echo "##### Modify the databases #####"

sudo -u postgres psql <<EOF

ALTER DATABASE $EXISTING_DSPACE_DATABASE_NAME RENAME TO $EXISTING_DSPACE_DATABASE_NAME_CHANGED;

\c $EXISTING_DSPACE_DATABASE_NAME_CHANGED

ALTER DATABASE $NEW_DSPACE_DATABASE_NAME RENAME TO $EXISTING_DSPACE_DATABASE_NAME;

\q

EOF

echo "#####  Show database info  #####"

sudo /srv/oulib/dspace/bin/dspace database info

echo "#####  Running database upgrade script  #####"

sudo /srv/oulib/dspace/bin/dspace database migrate

echo "#####  Copy over the registry files  #####"
sudo mv /srv/oulib/dspace/config/registries/ /srv/oulib/dspace/config/registries-old/
sudo mkdir /tmp/registries && sudo tar -xvf $PATH_TO_REGISTRIES_FROM_OLD_DSPACE -C /tmp/registries --strip-components=2
sudo mv /tmp/registries /srv/oulib/dspace/config
sudo chown -R tomcat:tomcat /srv/oulib/dspace/config/registries/

echo "#####  Restart Tomcat service  #####"
sudo systemctl start tomcat

echo "#####  Finished Database section  #####"
exit
