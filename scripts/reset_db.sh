#! /bin/bash

if [ $# -eq 0 ]; then
    >&2 echo "Need to pass the name of the target database as an argument: ./reset_db.sh jrpl_stg"
    exit 1
fi

DB=$1

psql -c "DROP DATABASE IF EXISTS $DB;"
createdb $DB -O $DB
psql -d $DB -f '../data/schema.sql'
psql -d $DB -f '../data/euro_2024_data.sql'
