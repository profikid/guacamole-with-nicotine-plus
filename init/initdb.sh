#!/bin/sh

set -e

/opt/guacamole/bin/initdb.sh --postgres > /opt/guacamole/init/initdb.sql
PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOSTNAME -U $POSTGRES_USER -d $POSTGRES_DATABASE -f /opt/guacamole/init/initdb.sql
