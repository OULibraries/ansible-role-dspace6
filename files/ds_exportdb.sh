#!/bin/bash
. /opt/oulib/dspace/etc/conf.sh



# Read database config from dspace config
DS_CFG="${DSPACE_RUN}/config/dspace.cfg"
DS_DB_URL=`cat $DS_CFG | grep ^db.url | cut -d "=" -f 2 | xargs`
DS_DB_HOST=`echo $DS_DB_URL | cut -d "/" -f 3 | cut -d ":" -f 1`
DS_DB_PORT=`echo $DS_DB_URL | cut -d "/" -f 3 | cut -d ":" -f 2`
DS_DB=`echo $DS_DB_URL | cut -d "/" -f 4 | xargs`
DS_DB_USER=`cat $DS_CFG | grep ^db.username | cut -d "=" -f 2 | xargs`
DS_DB_PASS=`cat $DS_CFG | grep ^db.password | cut -d "=" -f 2 | xargs`

# Dump the currently active database to the export file
export PGPASSWORD=$DS_DB_PASS
pg_dump --encoding utf8 -ocv -U "$DS_DB_USER" -h "$DS_DB_HOST"  "$DS_DB" > "$DB_EXPORT"
