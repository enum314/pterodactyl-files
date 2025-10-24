#!/bin/bash
psql -h 127.0.0.1 -At -U ${PGUSER} --dbname ${PGDBNAME} \
  -c "SELECT rolname, rolpassword FROM pg_authid WHERE rolpassword LIKE 'SCRAM-SHA-256%';" \
  | awk -F '|' '{print "\"" $1 "\" \"" $2 "\""}' > /home/container/pgbouncer/userlist.txt